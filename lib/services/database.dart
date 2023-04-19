import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  Future<String> chat(String query) async {
    final body = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": query}
      ],
    });
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        body: body,
        headers: <String, String>{
          'Authorization':
              'Bearer ${dotenv.env['api']}',
          'content-type': 'application/json'
        });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    }

    return response.body;
  }

  Future<String> complete(String query) async {
    final body = json.encode({
      "model": "text-davinci-003",
      "prompt": query,
      "max_tokens": 2700,
      "temperature": 1,
      "top_p": 1,
      "n": 1,
      "stream": false,
    });
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        body: body,
        headers: <String, String>{
          'Authorization':
              'Bearer ${dotenv.env['api']}',
          'content-type': 'application/json'
        });
    //
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['text'];
    }

    return 'some error occured';
  }

  Future<String> image(String query) async {
    final body = json.encode({"prompt": query, "n": 1, "size": "1024x1024"});
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        body: body,
        headers: <String, String>{
          'Authorization':
              'Bearer ${dotenv.env['api']}',
          'content-type': 'application/json'
        });

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['data'][0]['url'];
    }

    return data['error']['message'];
  }

  Future<String> audio(String query) async {
    final body = json.encode({
      "model": "gpt-3.5-turbo", 
      "messages": [
        {"role": "user", "content": query}
      ],
    });
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        body: body,
        headers: <String, String>{
          'Authorization':
              'Bearer ${dotenv.env['api']}',
          'content-type': 'application/json'
        });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    }

    return 'some error occured';
  }
}
