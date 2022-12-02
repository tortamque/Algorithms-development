import 'package:flutter_test/flutter_test.dart';
import '../lib/classes/DBManager.dart';
import '../lib/classes/records.dart';
import 'classes/DBTester.dart';

void main(){
  test("Add record", (){
    //arrange

    // ліст IndexRecord до тесту, який також включає порожні записи
    List<IndexRecord> indexElemetsBeforeTest = DBManager.instance.readIndexFile();
    // "відсіюємо" порожні записи і отримуємо їх кількість
    int nonEmptyIndexElemetsAmountBeforeTest = DBManager.instance.cutEmptyRecords(indexElemetsBeforeTest).length;
    // кількість записів з основної області до тесту
    int scopeElementsAmountBeforeTest = DBManager.instance.readScopeFile().length;
    // кількість записів з області переповнення до тесту
    int overflowElementsAmountBeforeTest = DBManager.instance.readOverflowFile().length;

    String recordValue = "test value";
    ScopeRecord recordToInsert = ScopeRecord(0, DBManager.instance.getLastScopeFileIndex() + 1, recordValue);

    //act

    DBManager.instance.addRecord(recordToInsert);

    //assert

    // ліст IndexRecord після тесту, який також включає порожні записи
    List<IndexRecord> indexElemetsAfterTest = DBManager.instance.readIndexFile();
    // "відсіюємо" порожні записи і отримуємо їх кількість
    int nonEmptyIndexElemetsAmountAfterTest = DBManager.instance.cutEmptyRecords(indexElemetsAfterTest).length;
    // кількість записів з основної області після тесту
    int scopeElementsAmountAfterTest = DBManager.instance.readScopeFile().length;
    // кількість записів з області переповнення після тесту
    int overflowElementsAmountAfterTest = DBManager.instance.readOverflowFile().length;

    // якщо індексна область не переповнена
    if(DBManager.instance.isIndexTableFull(indexElemetsAfterTest) == false){
      // очікуємо, що кількість записів індексної області після тесту = кількості записів індексної області до тесту + 1
      // (тобто запис додався в індексну область)
      expect(nonEmptyIndexElemetsAmountAfterTest, nonEmptyIndexElemetsAmountBeforeTest + 1);  
    }
    // якщо індексна область переповнена
    else{
      // очікуємо, що кількість записів області переповнення після тесту = кількості записів області переповнення до тесту + 1
      // (тобто запис додався в область переповнення)
      expect(overflowElementsAmountAfterTest, overflowElementsAmountBeforeTest + 1);
    }
    
    // очікуємо, що кількість записів основної області після тесту = кількості записів основної області до тесту + 1
    // (тобто запис додався в основну область)
    expect(scopeElementsAmountAfterTest, scopeElementsAmountBeforeTest + 1);
  });

  test("Delete record", (){
    //arrange

    // ліст IndexRecord до тесту, який також включає порожні записи
    List<IndexRecord> indexElemetsBeforeTest = DBManager.instance.readIndexFile();
    // "відсіюємо" порожні записи і отримуємо їх кількість
    int nonEmptyIndexElemetsAmountBeforeTest = DBManager.instance.cutEmptyRecords(indexElemetsBeforeTest).length;
    // кількість елементів основної області
    int scopeElementsAmount = DBManager.instance.readScopeFile().length;
    // запис для видалення
    // (беремо останній запис із бд)
    int recordNumberToDelete = DBTester.instance.getLastScopeRecordNumber();

    //act

    DBManager.instance.deleteRecord(recordNumberToDelete);

    //assert

    // ліст IndexRecord після тесту, який також включає порожні записи
    List<IndexRecord> indexElemetsAfterTest = DBManager.instance.readIndexFile();
    // "відсіюємо" порожні записи і отримуємо їх кількість
    int nonEmptyIndexElemetsAmountAfterTest = DBManager.instance.cutEmptyRecords(indexElemetsAfterTest).length;
    // запис після тестування
    ScopeRecord recordAfterTest = DBTester.instance.findScopeRecordByRecordNumber(recordNumberToDelete);

    // якщо основна область не порожня
    if(scopeElementsAmount > 0){
      // очікуємо, що к-сть елементів індексної області після тесту = к-сть елементів до тесту - 1
      expect(nonEmptyIndexElemetsAmountAfterTest, nonEmptyIndexElemetsAmountBeforeTest - 1);
      // очікуємо, що елемент буде помічсено як видалений
      expect(recordAfterTest.isDeleted, 1);
    }
    else{
      // очікуємо, що к-сть елементів індексної області не змінилась
      expect(nonEmptyIndexElemetsAmountAfterTest, nonEmptyIndexElemetsAmountBeforeTest);
    }
  });

  test("Find record", (){
    //arrange

    // отримуємо всі елементи індексної області
    var indexFile = DBManager.instance.readIndexFile();
    // ключ останнього елементу індексної області
    int indexTableKey = DBTester.instance.getLastIndexRecordKey();
    // знайдений запис індексної області 
    // (за допомогою бінарного пошуку)
    var foundIndexRecord = DBTester.instance.binarySearchIndexScopeByKey(indexFile, indexTableKey);
    // отримуємо всі елементи основної області
    var scopeFile = DBManager.instance.readScopeFile();
    // шукаємо елемент в основній області
    var manuallyFoundRecord = DBTester.instance.searchMainScope(scopeFile, foundIndexRecord.reference);


    //act

    ScopeRecord foundRecord = DBManager.instance.findRecord(indexTableKey);

    //assert

    expect(manuallyFoundRecord, foundRecord);
  });

  test("Edit record", (){
      //arrange

      // номер запису для зміни 
      // (беремо останній з основної області)
      int scopeRecordToEditRecordNumber = DBTester.instance.getLastScopeRecordNumber();
      String newValue = "This value was edited from unit test";


      //act

      DBManager.instance.editRecord(scopeRecordToEditRecordNumber, newValue);

      //assert
      ScopeRecord recordAfterTest = DBTester.instance.findScopeRecordByRecordNumber(scopeRecordToEditRecordNumber);

      expect(recordAfterTest.value, newValue);
  });
}