/** @name: DocumentPrintJSONGeneratorTest
 *  @description: test class for DocumentPrintJSONGenerator
**/
@isTest
public class DocumentPrintJSONGeneratorTest {
    
    @isTest
    static void DocumentPrintJSONGeneratorTest() {
         DocumentPrintJSONGenerator doc1 = new  DocumentPrintJSONGenerator();
        doc1 = DocumentPrintJSONGenerator.parse('{"name": "John", "age": 30, "city": "New York"}');
    }
}