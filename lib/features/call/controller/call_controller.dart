import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/call_model.dart';
import '../screen/call_screen.dart';
import '../screen/incoming_call_screen.dart';

class CallController extends GetxController {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Logged in user info
  final String myUid;
  final String myName;

  CallController({
    required this.myUid,
    required this.myName,
  });

  // Agora App ID
  static const String agoraAppId = "dbd7049202af4cb1a4c8b4b614162763";

  // Temporary Agora token (24h valid)
  static const String tempAgoraToken =
      "007eJxTYNB12160Ps6k4/HGa8wnZOK2vnUVc512MP78zV1sS+UEP3AoMKQkpZgbmFgaGRglppkkJxkmmiRbJJkkmRmaGJoZmZsZq/PGZjYEMjLw27xmZWSAQBCflSExPb8okYEBACczHew=";

  // Agora engine
  late RtcEngine engine;

  // Incoming call data
  Rx<CallModel?> incomingCall = Rx<CallModel?>(null);

  // Remote user uid for video
  RxInt remoteUid = 0.obs;

  // Call state
  RxBool isInCall = false.obs;

  // Prevent multiple incoming call screens
  bool _incomingScreenOpen = false;

  @override
  void onInit() {
    super.onInit();
    listenIncomingCalls();
  }

  // Initialize Agora video call
  Future<void> initAgora(String channelId) async {
    await [
      Permission.camera,
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

    await engine.enableVideo();
    await engine.startPreview();

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          remoteUid.value = uid;
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          remoteUid.value = 0;
        },
      ),
    );

    await engine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    await engine.joinChannel(
      token: tempAgoraToken,
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    isInCall.value = true;
  }

  // Start call as caller
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

  // End call
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
    remoteUid.value = 0;

    Get.back();
  }
}
