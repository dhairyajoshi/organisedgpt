import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:organisedgpt/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation.dart';

class DatabaseService {
  String baseUrl = 'https://organisedgpt-backend.onrender.com';

  Future<bool> login(String uname, String pass) async {
    final response = await http.post(Uri.parse('${baseUrl}/user/login'),
        body: {'username': uname, 'password': pass});

    final data = json.decode(response.body);

    final pref = await SharedPreferences.getInstance();

    if (response.statusCode == 200) {
      final token = data['token'];
      pref.setString('token', token);
      pref.setString('api', data['user']['token']);
      return true;
    }
    return false;
  }

  Future<bool> signUp(UserModel user) async {
    final response = await http.post(Uri.parse('${baseUrl}/user/signup'),
        body: user.toJson());

    final data = json.decode(response.body);

    final pref = await SharedPreferences.getInstance();

    if (response.statusCode == 201) {
      final token = data['token'];
      pref.setString('token', token);
      pref.setString('api', user.token);
      return true;
    }
    return false;
  }

  Future<List<ChatModel>> getChats() async {
    List<ChatModel> chats = [];
    final pref = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('${baseUrl}/conv/getchats'),
        headers: {'Authorization': 'Bearer ${pref.getString('token')}'});
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      for (int i = 0; i < data['chats'].length; i++) {
        chats.add(ChatModel(data['chats'][i]['id'], data['chats'][i]['name']));
      }
    }

    return chats;
  }

  Future<List<ChatModel>> getMessages(String id) async {
    List<ChatModel> chats = [];
    final pref = await SharedPreferences.getInstance();
    final response = await http.get(
        Uri.parse('${baseUrl}/conv/getmessages?id=${id}'),
        headers: {'Authorization': 'Bearer ${pref.getString('token')}'});
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      for (int i = 0; i < data['chats'].length; i++) {
        chats.add(ChatModel(data['chats'][i]['id'], data['chats'][i]['name']));
      }
    }

    return chats;
  }

  Future<bool> createChat(String name) async {
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse('${baseUrl}/conv/createchat'),
        headers: {'Authorization': 'Bearer ${pref.getString('token')}'},
        body: {"name": name});
    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> addMessage(List<ChatModel> chats, String id) async {
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.parse('${baseUrl}/conv/addmessages?id=$id'),
        headers: {'Authorization': 'Bearer ${pref.getString('token')}'},
        body: {chats});
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  void updateMessages(List<ChatModel> chats, String id) async {
    List<ChatModel> chats = [];
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.parse('${baseUrl}/conv/updatemessages'),
        headers: {'Authorization': 'Bearer ${pref.getString('token')}'},
        body: {'chatId': id, 'messages': chats});
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      print(data);
    }
  }

  Future<String> chat(String query, double temp, int len) async {
    final body = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": query}
      ],
      "max_tokens": len,
      "temperature": temp,
    });
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        body: body,
        headers: <String, String>{
          'Authorization': 'Bearer ${pref.getString('api')}',
          'content-type': 'application/json'
        });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    }

    return response.body;
  }

  Future<String> complete(String query, double temp, int len) async {
    final body = json.encode({
      "model": "text-davinci-003",
      "prompt": query,
      "max_tokens": len,
      "temperature": temp,
      "top_p": 1,
      "n": 1,
      "stream": false,
    });
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        body: body,
        headers: <String, String>{
          'Authorization': 'Bearer ${pref.getString('api')}',
          'content-type': 'application/json'
        });
    //
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['choices'][0]['text'];
    }

    return response.body;
  }

  Future<List<Message>> image(String query, int n, int sz) async {
    List<String> size = ['256x256', '512x512', '1024x1024'];
    final body = json.encode({"prompt": query, "n": n, "size": size[sz]});
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        body: body,
        headers: <String, String>{
          'Authorization': 'Bearer ${pref.getString('api')}',
          'content-type': 'application/json'
        });

    final data = json.decode(response.body);
    List<Message> res = [];
    if (response.statusCode == 200) {
      for (int i = 0; i < data['data'].length; i++) {
        res.add(Message(1, data['data'][i]['url'], 1, 1));
      }
      return res;
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
    final pref = await SharedPreferences.getInstance();
    final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        body: body,
        headers: <String, String>{
          'Authorization': 'Bearer ${pref.getString('api')}',
          'content-type': 'application/json'
        });

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data['choices'][0]['message']['content'];
    }

    return response.body;
  }
}
