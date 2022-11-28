// запис індексної області
class IndexRecord{
  // ключ
  final int key;
  // посилання на recordNumber з основної області
  final int reference;

  // конструктор
  IndexRecord(this.key, this.reference);

  @override
  String toString(){
    return "${key} : ${reference}";
  }
}

// запис основної області
class ScopeRecord{
  // чи видалений запис (0 - ні, 1 - так)
  int isDeleted;
  // номер запису
  final int recordNumber;
  // значення запису
  String value;

  // конструктор
  ScopeRecord(this.isDeleted, this.recordNumber, this.value);

  @override
  String toString(){
    return "${isDeleted} : ${recordNumber} : ${value}";
  }

  @override
  bool operator == (Object anotherRecord){
    if(anotherRecord is ScopeRecord){
      return isDeleted == anotherRecord.isDeleted 
             && recordNumber == anotherRecord.recordNumber
             && value == anotherRecord.value;
    }
    return false;
  }
  
}