import 'dart:io';
import '../../lib/classes/DBManager.dart';
import '../../lib/classes/records.dart';

class DBTester{
  // використовуємо патерн Singleton
  // (клас матиме тільки один екземпляр, 
  // і ми будемо мати глобальну точку доступу до цього екземпляра)
  static final DBTester instance = DBTester._init();
  DBTester._init();

  int getLastScopeRecordNumber(){
    var scopeFileElements = DBManager.instance.readScopeFile();
    int lastRecordNumber = 0;

    scopeFileElements.length > 0
    ? lastRecordNumber = scopeFileElements[scopeFileElements.length - 1].recordNumber
    : lastRecordNumber = 0;

    return lastRecordNumber;
  }

  ScopeRecord findScopeRecordByRecordNumber(int number){
    var scopeFileElements = DBManager.instance.readScopeFile();

    for (var record in scopeFileElements) {
      if(record.recordNumber == number){
        return record;
      }
    }

    return ScopeRecord(0, 0, "");
  }

  int getLastIndexRecordKey(){
    var indexFileElements = DBManager.instance.readIndexFile();
    // "відсіюємо" порожні записи і отримуємо їх кількість
    var nonEmptyIndexElemets = DBManager.instance.cutEmptyRecords(indexFileElements);
    int lastIndexRecordKey = 0;

    nonEmptyIndexElemets.length > 0
    ? lastIndexRecordKey = nonEmptyIndexElemets[nonEmptyIndexElemets.length - 1].key
    : lastIndexRecordKey = 0;

    return lastIndexRecordKey;
  }

  ScopeRecord searchMainScope(List<ScopeRecord> list, int index){
    for (var record in list) {
      if(record.recordNumber == index){
        return record;
      }
    }
    //return null;
    return ScopeRecord(0, 0, "Empty");
  }

  // за допомогою бінарного пошуку шукаємо запис в індексній області
  IndexRecord binarySearchIndexScopeByKey(List<IndexRecord> list, int index){
    // відсіяний ліст (не має порожніх записів)
    List<IndexRecord> cuttedList = DBManager.instance.cutEmptyRecords(list);

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
}