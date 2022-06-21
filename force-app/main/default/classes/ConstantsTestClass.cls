@isTest
public with sharing class ConstantsTestClass{
    @isTest 
    public static void constantsTestMethod(){
        Constants cons = new Constants();
        System.assert(cons != Null, 'cons is Null');
    }
    @isTest 
    public static void constantsTestMethod2(){
        ConstantsTest cons = new ConstantsTest();
        System.assert(cons != Null, 'cons is Null');
    }
}