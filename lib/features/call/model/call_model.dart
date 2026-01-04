class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String channelId;
  final String status; // ringing, accepted, rejected, ended

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.channelId,
    required this.status,
  });

  factory CallModel.fromJson(Map<String, dynamic> json, String id) {
    return CallModel(
      callId: id,
      callerId: json['callerId'],
      callerName: json['callerName'],
      receiverId: json['receiverId'],
      channelId: json['channelId'],
      status: json['status'],
    );
  }
}
