class OtpChallengeModel {
  final bool success;
  final String message;
  final String? challengeId;
  final int? expiresIn;
  final int? resendAfter;

  OtpChallengeModel({
    required this.success,
    required this.message,
    this.challengeId,
    this.expiresIn,
    this.resendAfter,
  });

  factory OtpChallengeModel.fromJson(Map<String, dynamic> json) {
    return OtpChallengeModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      challengeId: json['challenge_id'],
      expiresIn: json['expires_in'],
      resendAfter: json['resend_after'],
    );
  }
}

class AuthResponseModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
