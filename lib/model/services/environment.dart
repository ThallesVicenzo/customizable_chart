import 'package:flutter_dotenv/flutter_dotenv.dart';

const String endpoint = 'https://api.githubcopilot.com/chat/completions';

String? get authToken => dotenv.env['GITHUB_COPILOT_TOKEN'];
