import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Don't forget to import the http package
import 'dart:convert'; // Import this to use jsonEncode and jsonDecode

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SimpleUI(),
    );
  }
}

class SimpleUI extends StatefulWidget {
  @override
  _SimpleUIState createState() => _SimpleUIState();
}

class _SimpleUIState extends State<SimpleUI> {
  final inputController = TextEditingController();
  String resultText = '';
  List<String> resultList = [];
  String selectedOption = 'Option 1';
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UI 확장 예시')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: inputController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  resultText = inputController.text;
                });
              },
              child: Text('Show Result'),
            ),
            SizedBox(height: 20),
            Text(resultText),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  resultList.add(inputController.text);
                });
              },
              child: Text('Add to List'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  String result = "${inputController.text} - $selectedOption";
                  if (isChecked) {
                    result += " (Enabled)";
                  }
                  resultList.add(result);
                });
              },
              child: Text('Add to List with Options'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: resultList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(resultList[index]),
                  );
                },
              ),
            ),
            DropdownButton<String>(
              value: selectedOption,
              items: <String>['Option 1', 'Option 2', 'Option 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Enable Option'),
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
            // New ElevatedButton for calculation
            ElevatedButton(
              onPressed: () async {
                await getOpenAIResponse(inputController.text); // Call the new function
              },
              child: Text('계산하기'), // This button now performs the calculation
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getOpenAIResponse(String input) async {
    const apiKey =
        'sk-';
    final url = '';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Organization': 'org-qGKqo4eFq3qP4FoVarwAEhdY',
        'OpenAI-Project': 'proj_rzRFceMjLlY7VWfYPTsNO6we',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an assistant specialized in helping only with calculations.'
          },
          {'role': 'user', 'content': input}, // 사용자의 입력을 반영
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        print(data);
        resultText = data['choices'][0]['message']['content'];
      });
    } else {
      // 에러 메시지를 상세히 표시
      setState(() {
        resultText =
            'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}';
      });
    }
  }
}
