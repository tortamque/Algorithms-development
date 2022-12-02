import 'package:flutter/material.dart';

import '../classes/records.dart';
import '../classes/DBManager.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
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
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        DBManager.instance.initializeDatabase();

                        updateDatabase();
                      });
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text("Initialize database", style: TextStyle(color: Colors.grey[800]),)
                    ),
                  ),
                ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Index Table:", style: TextStyle(fontWeight: FontWeight.bold),),
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
              ),
            ],
          )
        ),
      )
    );
  }
}