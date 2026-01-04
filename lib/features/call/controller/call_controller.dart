import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/call_model.dart';
import '../screen/call_screen.dart';
import '../screen/incoming_call_screen.dart';

class CallController extends GetxController {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user info
  final String myUid;
  final String myName;

  CallController({
    required this.myUid,
    required this.myName,
  });

  // Agora App ID
  static const String agoraAppId = "dbd7049202af4cb1a4c8b4b614162763";

  // Agora engine
  late RtcEngine engine;

  // Incoming call data
  Rx<CallModel?> incomingCall = Rx<CallModel?>(null);

  // Call state
  RxBool isInCall = false.obs;

  // Prevent multiple incoming screens
  bool _incomingScreenOpen = false;

  @override
  void onInit() {
    super.onInit();
    listenIncomingCalls(); // Start listening for calls
  }

  // Get Agora token from Firebase Function
  Future<String> fetchAgoraToken(String channelId) async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('generateAgoraToken')
        .call({
      'channelName': channelId,
      'uid': myUid.hashCode,
    });

    return result.data['token'];
  }

  // Initialize Agora voice call
  Future<void> initAgora(String channelId) async {
    await [
      Permission.microphone,
      Permission.bluetoothConnect,
    ].request();

    engine = createAgoraRtcEngine();

    await engine.initialize(
      const RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await engine.enableAudio();
    await engine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    final token = await fetchAgoraToken(channelId);

    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: myUid.hashCode,
      options: const ChannelMediaOptions(),
    );

    isInCall.value = true;
  }

  // Start a call as caller
  Future<void> startCall({
    required String receiverId,
    required String receiverName,
  }) async {
    final doc = _firestore.collection('calls').doc();
    final channelId = 'voice_${myUid}_$receiverId';

    await doc.set({
      'callerId': myUid,
      'callerName': myName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'channelId': channelId,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    Get.to(() => CallScreen(channelId: channelId));
    await initAgora(channelId);
  }

  // Listen for incoming calls
  void listenIncomingCalls() {
    _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: myUid)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty && !_incomingScreenOpen) {
        final doc = snapshot.docs.first;
        incomingCall.value = CallModel.fromJson(doc.data(), doc.id);

        _incomingScreenOpen = true;
        Get.to(() => IncomingCallScreen())!.then((_) {
          _incomingScreenOpen = false;
        });
      }
    });
  }

  // Accept incoming call
  Future<void> acceptCall() async {
    final call = incomingCall.value!;

    await _firestore
        .collection('calls')
        .doc(call.callId)
        .update({'status': 'accepted'});

    Get.off(() => CallScreen(channelId: call.channelId));
    await initAgora(call.channelId);
  }

  // End or reject call
  Future<void> endCall() async {
    if (isInCall.value) {
      await engine.leaveChannel();
      await engine.release();
    }

    if (incomingCall.value != null) {
      await _firestore
          .collection('calls')
          .doc(incomingCall.value!.callId)
          .update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
    }

    isInCall.value = false;
    incomingCall.value = null;

    Get.back();
  }
}
