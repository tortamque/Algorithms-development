import 'package:flutter/material.dart';

import '../classes/records.dart';
import '../classes/DBManager.dart';


class RemovePage extends StatefulWidget {
  const RemovePage({super.key});

  @override
  State<RemovePage> createState() => _RemovePageState();
}

class _RemovePageState extends State<RemovePage> {
  TextEditingController indexController = TextEditingController();

  List<IndexRecord> indexRecords = [];
  List<ScopeRecord> scopeRecords = [];
  List<IndexRecord> overflowRecords = [];
  

  @override
  void initState(){
    unpackDatabase();
  }

  void unpackDatabase(){
    var indexResult = DBManager.instance.readIndexFile();
    var scopeResult = DBManager.instance.readScopeFile();
    var overflowResult = DBManager.instance.readOverflowFile();


    setState(() {
      indexRecords = indexResult.map((element) => IndexRecord(element.key, element.reference)).toList();
      scopeRecords = scopeResult.map((element) => ScopeRecord(element.isDeleted, element.recordNumber, element.value)).toList();
      overflowRecords = overflowResult.map((element) => IndexRecord(element.key, element.reference)).toList();
    });
  }

  List<DataRow> buildIndexTableRows(List<IndexRecord> records){
    return records.map((element) => DataRow(
      cells: [
          DataCell(Text(element.key.toString())), 
          DataCell(Text(element.reference.toString()))
        ]
      )
    ).toList();
  }

  List<DataRow> buildScopeTableRows(List<ScopeRecord> records){
    return records.map((element) => DataRow(
      cells: [
          DataCell(Text(element.isDeleted.toString())), 
          DataCell(Text(element.recordNumber.toString())),
          DataCell(Text(element.value)),
        ]
      )
    ).toList();
  }

  void updateDatabase(){
    indexRecords = DBManager.instance.readIndexFile().map((element) => IndexRecord(element.key, element.reference)).toList();
    scopeRecords = DBManager.instance.readScopeFile().map((element) => ScopeRecord(element.isDeleted, element.recordNumber, element.value)).toList();
    overflowRecords = DBManager.instance.readOverflowFile().map((element) => IndexRecord(element.key, element.reference)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent),),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue),),
                    labelText: 'Scope table record number',
                  ),
                  controller: indexController,
                ),
                  
                Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            int scopeRecordToDeleteIndex = int.parse(indexController.text);
                            DBManager.instance.deleteRecord(scopeRecordToDeleteIndex);

                            updateDatabase();
                            
                            indexController.text = "";
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text("Delete", style: TextStyle(color: Colors.grey[800]),)
                        ),
                      ),
                    ),

                const Padding(padding: EdgeInsets.only(bottom: 40), child: Text("Database", style: TextStyle(fontWeight: FontWeight.bold),),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Scope table record number:", style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("key"), numeric: true),
                              DataColumn(label: Text("reference"), numeric: true),
                            ],
                            rows: [
                              ...buildIndexTableRows(indexRecords)
                            ],
                          ),
                        ),
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Scope Table:", style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("isDeleted "), numeric: true),
                              DataColumn(label: Text("recordNumber "), numeric: true),
                              DataColumn(label: Text("value")),
                            ],
                            rows: [
                              ...buildScopeTableRows(scopeRecords)
                            ],
                          ),
                        ),
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Overflow Table:", style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("key"), numeric: true),
                              DataColumn(label: Text("reference"), numeric: true),
                            ],
                            rows: [
                              ...buildIndexTableRows(overflowRecords)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}