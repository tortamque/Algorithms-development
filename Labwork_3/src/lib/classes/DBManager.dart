import 'dart:io';
import '../classes/records.dart';

class DBManager{
  // використовуємо патерн Singleton
  // (клас матиме тільки один екземпляр, 
  // і ми будемо мати глобальну точку доступу до цього екземпляра)
  static final DBManager instance = DBManager._init();
  DBManager._init();

  // шлях до індексного файлу
  //final String _indexFilePath = "F:/Projects/Flutter/Labwork_3/lib/files/index_file.txt";
  final String _indexFilePath = "${Directory.current.path}/files/index_file.txt";
  // шлях до файлу переповнення
  //final String _overflowFilePath = "F:/Projects/Flutter/Labwork_3/lib/files/overflow_file.txt";
  final String _overflowFilePath = "${Directory.current.path}/files/overflow_file.txt"; 
  // шлях до файлу основної області
  //final String _scopeFilePath = "F:/Projects/Flutter/Labwork_3/lib/files/scope_file.txt";
  final String _scopeFilePath = "${Directory.current.path}/files/scope_file.txt"; 

  // розмір блоку (включаючи область переповнення)
  final int blockSize = 5;
  // кількість блоків
  final int _blocksAmount = 5;

  // читаємо індексний файл
  List<IndexRecord> readIndexFile(){
    // результат (ліст з об'єктами IndexRecord)
    List<IndexRecord> result = [];

    // файл
    File file = File(_indexFilePath);
    // вміст файлу
    var fileContent = file.readAsStringSync();
    // розбиваємо файл на лінії
    var fileContentLines = fileContent.split('\n');

    // для кожного елементу fileContentLines
    fileContentLines.forEach((element) {
      // якщо лінія != "key : reference"
      if(!element.contains("key : reference")){
        // парсимо ключ
        int indexKey = int.parse(element.split(" : ")[0]);
        // парсимо посилання
        int indexReference = int.parse(element.split(" : ")[1]);

        // створюємо об'єкт IndexRecord
        IndexRecord record = IndexRecord(indexKey, indexReference);
        
        // додаємо об'єкт в ліст result
        result.add(record);
      }
    },);

    return result;
  }

  // читаємо файл переповнення (аналогічно до індексного файлу)
  List<IndexRecord> readOverflowFile(){
    List<IndexRecord> result = [];

    File file = File(_overflowFilePath);
    var fileContent = file.readAsStringSync();
    var fileContentLines = fileContent.split('\n');

    fileContentLines.forEach((element) {
      if(!element.contains("key : reference")){
        int indexKey = int.parse(element.split(" : ")[0]);
        int indexReference = int.parse(element.split(" : ")[1]);

        IndexRecord record = IndexRecord(indexKey, indexReference);
        
        result.add(record);
      }
    },);

    return result;
  }

  // читаємо файл основної області (аналогічно до індексного файлу)
  List<ScopeRecord> readScopeFile(){
    List<ScopeRecord> result = [];

    File file = File(_scopeFilePath);
    var fileContent = file.readAsStringSync();
    var fileContentLines = fileContent.split('\n');

    fileContentLines.forEach((element) {
      if(!element.contains("isDeleted : recordNumber : value")){
        // парсимо поле, чи видалений елемент
        int isDeleted = int.parse(element.split(" : ")[0]);
        // парсимо номер запису
        int recordNumber = int.parse(element.split(" : ")[1]);
        // парсимо значення
        String value = element.split(" : ")[2];

        result.add(ScopeRecord(isDeleted, recordNumber, value));
      }
    },);

    return result;
  }

  // "відсіюємо" порожні записи із ліста IndexRecord
  List<IndexRecord> cutEmptyRecords(List<IndexRecord> list){
    List<IndexRecord> cuttedList = [];

    for (var record in list) {
      if(record.key != 0 && record.reference != 0){
        cuttedList.add(record);
      }
    }

    return cuttedList;
  }

  // за допомогою бінарного пошуку шукаємо запис в індексній області
  IndexRecord _binarySearchIndexScopeByKey(List<IndexRecord> list, int index){
    // відсіяний ліст (не має порожніх записів)
    List<IndexRecord> cuttedList = cutEmptyRecords(list);

    // лівий індекс
    int left = 0;
    // правий індекс
    int right = cuttedList.length - 1;
    // центральний індекс
    int middle;

    while(left <= right){
      // рахуємо центральний індекс
      middle = ((right - left)/2 + left).round();

      // якщо заданий індекс == індексу шуканого елементу
      if(index == cuttedList[middle].key){
        // повертаємо шуканий елемент
        return cuttedList[middle];
      } 
      // якщо заданий індекс менший індексу шуканого елементу
      else if (index < cuttedList[middle].key){
        // змінюємо правий індекс
        right = middle - 1;
      } 
      else{
        // змінюємо лівий індекс
        left = middle + 1;
      }
    }

    //якщо елемент не знайдено, то повертаємо порожній IndexRecord
    return IndexRecord(0, 0);
  }

  // знаходимо IndexRecord за посиланням
  IndexRecord _findIndexRecordByReference(List<IndexRecord> list, int ref){
    for (var record in list) {
      if(record.reference == ref){
        return record;
      }
    }

    //якщо елемент не знайдено, то повертаємо порожній IndexRecord
    return IndexRecord(0, 0);
  }

  // заповнюємо ліст порожніми елементами
  // (наприклад, якщо в лісті 5 елементів, 
  // але в нас 3 блоки по 5 елементів = загалом 15 елементів,
  // то потрібно додати ще 10 порожніх елементів)
  void _fillEmptyRecords(List<IndexRecord> list){
    int overallCapacity = blockSize * _blocksAmount;

    for(int i = list.length; i < overallCapacity; i += 1){
      list.add(IndexRecord(0, 0));
    }
  }

  // за подомогою бінарного пошуку видаляємо IndexRecord 
  // (аналогічно до функції _binarySearchIndexScopeByKey)
  List<IndexRecord> _binaryDeleteIndexRecord(List<IndexRecord> list, IndexRecord record){
    List<IndexRecord> cuttedList = cutEmptyRecords(list);

    int left = 0;
    int right = cuttedList.length - 1;
    int middle;

    while(left <= right){
      middle = ((right - left)/2 + left).round();

      if(record.key == cuttedList[middle].key){
        // замінюємо елемент на порожній
        cuttedList[middle] = IndexRecord(0, 0);
      } 
      else if (record.key < cuttedList[middle].key){
        right = middle - 1;
      } 
      else{
        left = middle + 1;
      }
    }

    // знову видаляємо порожні елементи (тому що в нас з'явився ще один) 
    // наприклад, якщо в нас є записи 1:2, 2:3 і 3:5 і потрібно видалити запис з ключем 1, 
    // то після видалення отримаємо такі записи: 0:0, 2:3 і 3:5, 
    // тому потрібно додатково видалити цей перший запис, який є порожнім
    cuttedList = cutEmptyRecords(cuttedList);
    // заповнюємо ліст порожніми елементами
    _fillEmptyRecords(cuttedList);

    return cuttedList;
  }
  
  // шукаємо елемент в основній області
  ScopeRecord _searchMainScope(List<ScopeRecord> list, int index){
    for (var record in list) {
      if(record.recordNumber == index){
        return record;
      }
    }
    //return null;
    return ScopeRecord(0, 0, "Empty");
  }

  // знаходимо елемент ScopeRecord по ключу IndexRecord
  ScopeRecord findRecord(int indexKey){
    // отримуємо всі елементи індексної області
    var indexFile = readIndexFile();
    // знаходимо елемент індексної області, який містить потрібний ключ
    var foundIndexRecord = _binarySearchIndexScopeByKey(indexFile, indexKey);

    // отримуємо всі елементи основної області
    var scopeFile = readScopeFile();
    // знаходимо елемент основної області, який містить потрібний ключ 
    // (тобто посилання із індексної області)
    var foundScopeRecord = _searchMainScope(scopeFile, foundIndexRecord.reference);

    return foundScopeRecord;
  }

  // записуємо елементи в файл індексної області
  void _writeIndexFile(List<IndexRecord> list){
    // файл
    File file = File(_indexFilePath);
    // вміст, який потрібно записати
    String contentToWrite = "key : reference\n";

    for (var record in list) {
      contentToWrite += "${record.toString()}\n";
    }

    // видаляємо останній символ \n
    contentToWrite = contentToWrite.substring(0, contentToWrite.length - 1);

    // записуэмо вміст у файл
    file.writeAsStringSync(contentToWrite);
  }

  // записуємо елементи в файл основної області (аналогічно до індексної)
  void _writeScopeFile(List<ScopeRecord> list){
    File file = File(_scopeFilePath);
    String contentToWrite = "isDeleted : recordNumber : value\n";

    for (var record in list) {
      contentToWrite += "${record.toString()}\n";
    }

    contentToWrite = contentToWrite.substring(0, contentToWrite.length - 1);

    file.writeAsStringSync(contentToWrite);
  }

  // записуємо елементи в файл області переповнення (аналогічно до індексної)
  void _writeOverflowFile(List<IndexRecord> list){
    File file = File(_overflowFilePath);
    String contentToWrite = "key : reference\n";

    for (var record in list) {
      contentToWrite += "${record.toString()}\n";
    }

    contentToWrite = contentToWrite.substring(0, contentToWrite.length - 1);

    file.writeAsStringSync(contentToWrite);
  }

  // отримуємо індекс останнього елементу основної області
  int getLastScopeFileIndex(){
    var scopeFileElements = readScopeFile();

    // якщо основна область не порожня
    if(scopeFileElements.length > 0){
      return scopeFileElements[scopeFileElements.length - 1].recordNumber;
    } 
    // якщо основна область порожня
    else{
      return 0;
    }
  }

  // рахуємо номер блоку, в який потрібно записати елемент
  int _defineBlock(int index){
    return index % blockSize == 0 
    ? ((index / blockSize) - 1).toInt()
    : (index / blockSize).floor();
  }

  // розбиваємо ліст з елементами IndexRecord на блоки (2D ліст/матрицю)
  List<List<IndexRecord>> _divideIndexFileToBlocks(List<IndexRecord> records){
    List<List<IndexRecord>> dividedList = [];

    List<IndexRecord> tempDividedList = [];
    for(int i = 0; i < records.length; i += 1){
      if(i % blockSize != 0 || i == 0){
        tempDividedList.add(records[i]);
      }
      else{
        dividedList.add(tempDividedList);
        tempDividedList = [];

        tempDividedList.add(records[i]);
      }
    }
    dividedList.add(tempDividedList);

    return dividedList;
  }

  // додаємо елемент у блок
  void _addItemToBlock(List<List<IndexRecord>> dividedIndexList, int blockNumber, IndexRecord item){
    // рахуємо його позицію всередині блоку
    int positionInsideBlock = (item.key - 1) % blockSize;
    // вставляємо елемент
    dividedIndexList[blockNumber][positionInsideBlock] = item;
  }

  // записуємо блоки індекснох області у файл
  void _writeIndexBlocks(List<List<IndexRecord>> blocks){
    File file = File(_indexFilePath);
    String contentToWrite = "key : reference\n";

    for (var block in blocks) {
      for(var item in block){
        contentToWrite += "${item.toString()}\n";
      }
    }

    // видаляємо останній символ \n
    contentToWrite = contentToWrite.substring(0, contentToWrite.length - 1);

    file.writeAsStringSync(contentToWrite);
  }

  // отримуємо останній запис індексної області
  IndexRecord _getLastIndexRecord(){
    var indexFileElements = readIndexFile();

    for(int i = indexFileElements.length - 1; i >= 0; i -= 1){
      if(indexFileElements[i].key != 0 && indexFileElements[i].reference != 0){
        return indexFileElements[i];
      }
    }

    return IndexRecord(0, 0);
  }

  // отримуємо останній запис області переповнення
  IndexRecord _getLastIndexRecordOverflowTable(){
    var indexFileElements = readOverflowFile();

    for(int i = indexFileElements.length - 1; i >= 0; i -= 1){
      if(indexFileElements[i].key != 0 && indexFileElements[i].reference != 0){
        return indexFileElements[i];
      }
    }

    return IndexRecord(0, 0);
  }

  // перевіряємо чи індексна область заповнена
  bool isIndexTableFull(List<IndexRecord> indexFileElements){
    // загальна місткість індексної області
    int overallCapacity = blockSize * _blocksAmount;
    // кількість непустих елементів
    int nonEmptyRecordCount = 0;

    for (var record in indexFileElements) {
      // якщо елемент не пустий
      if(record.key != 0 && record.reference != 0){
        nonEmptyRecordCount += 1;
      }
    }

    // повертаємо true, якщо кількість непустих елементів == місткості індексної області, 
    // інакше повертаємо false
    return nonEmptyRecordCount == overallCapacity ? true : false;
  }

  // додаємо запис
  void addRecord(ScopeRecord record){
    // елементи індексної області
    var indexFileElements = readIndexFile();
    // елементи основної області
    var scopeFileElements = readScopeFile();

    // створюємо об'єкт ScopeRecord
    var scopeRecordToAdd = ScopeRecord(record.isDeleted, record.recordNumber, record.value);
    // додаємо цей об'єкт в scopeFileElements
    scopeFileElements.add(scopeRecordToAdd);
    // записуємо scopeFileElements в файл основної області
    _writeScopeFile(scopeFileElements);

    // генеруємо ключ в залежності від того, що заповнена основна область
    int key = isIndexTableFull(indexFileElements)
    // якщо основна область заповнена
    // генеруємо ключ із області переповнення
    ? _getLastIndexRecordOverflowTable().key + 1
    // якщо основна область не заповнена
    // генеруємо ключ із індексної області
    : _getLastIndexRecord().key + 1;
    int reference = record.recordNumber;
    var indexRecordToAdd = IndexRecord(key, reference);
    
    // якщо індексна область не заповнена
    if(isIndexTableFull(indexFileElements) == false){
      // розбиваємо область на блоки
      var dividedIndexList = _divideIndexFileToBlocks(indexFileElements);
      // отримуємо блок в який потрібно запести запис
      int blockToAdd = _defineBlock(indexRecordToAdd.key);
      // заносимо запис у блок
      _addItemToBlock(dividedIndexList, blockToAdd, indexRecordToAdd);
      // записуємо блоки у файл
      _writeIndexBlocks(dividedIndexList);
    }
    // якщо індексна область заповнена
    else{
      // отримуємо записи з області переповнення
      var overflowItems = readOverflowFile();
      // додамо туди запис
      overflowItems.add(indexRecordToAdd);
      // записуємо все в область переповнення
      _writeOverflowFile(overflowItems);
    }
  }

  // помічаємо елемент як видалений 
  void _markRecordAsRemoved(List<ScopeRecord> records, int recordNumber){
    for (var record in records) {
      if(record.recordNumber == recordNumber){
        record.isDeleted = 1;
      }
    }
  }

  // видаляємо елемент
  void deleteRecord(int recordNumber){

    // елементи індексної області
    var indexFileElements = readIndexFile();
    // елементи основної області
    var scopeFileElements = readScopeFile();

    // помічаємо елемент як видалений
    _markRecordAsRemoved(scopeFileElements, recordNumber);
    // записуємо scopeFileElements в основну область
    _writeScopeFile(scopeFileElements);

    // отримуємо IndexRecord який потрібно видалити
    IndexRecord indexRecordToDelete = _findIndexRecordByReference(indexFileElements, recordNumber);
    // ліст з видаленим IndexRecord
    var removedIndexRecordList = _binaryDeleteIndexRecord(indexFileElements, indexRecordToDelete);
    // записуємо removedIndexRecordList в індексну область
    _writeIndexFile(removedIndexRecordList);
  }

  // змінюємо значення запису
  void _changeRecordValue(List<ScopeRecord> records, int recordNumber, String newValue){
    for (var record in records) {
      if(record.recordNumber == recordNumber){
        record.value = newValue;
      }
    }
  }

  // змінюємо запис
  void editRecord(int recordNumber, String newValue){
    // елементи основної області
    var scopeFileElements = readScopeFile();

    // змінюємо значення запису 
    _changeRecordValue(scopeFileElements, recordNumber, newValue);

    // записуємо scopeFileElements в основну область
    _writeScopeFile(scopeFileElements);
  }

  // ініціалізуємо базу даних
  void initializeDatabase(){
    // файл індексної області
    File indexFile = File(_indexFilePath);
    // файл основної області
    File scopeFile = File(_scopeFilePath);
    // файл області переповнення
    File overflowFile = File(_overflowFilePath);

    // записуємо "шапку" в основну область
    scopeFile.writeAsStringSync("isDeleted : recordNumber : value");
    // записуємо "шапку" в область переповнення
    overflowFile.writeAsStringSync("key : reference");

    // вміст, який потрібно записати
    String indexFileStringToWrite = "key : reference\n";
    // місткість індексної області
    int overallCapacity = _blocksAmount * blockSize;
    // формуємо "пусті" елементи
    for(int i = 0; i < overallCapacity; i += 1){
      IndexRecord record = IndexRecord(0, 0);
      indexFileStringToWrite += record.toString() + '\n';
    }
    // видаляємо останній символ "\n"
    indexFileStringToWrite = indexFileStringToWrite.substring(0, indexFileStringToWrite.length - 1);
    // записуємо indexFileStringToWrite в індексну область
    indexFile.writeAsStringSync(indexFileStringToWrite);
  }


}