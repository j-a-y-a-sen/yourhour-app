import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey = "YOUR_API_KEY";

  Future<String> getReply(String message) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a kind, supportive mental health listener. Be empathetic, calm, and comforting."
          },
          {"role": "user", "content": message}
        ]
      }),
    );

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}