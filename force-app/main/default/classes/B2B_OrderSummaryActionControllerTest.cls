/* Main Class - B2B_OrderSummaryActionController.cls */
@IsTest(SeeAllData=true)
public class B2B_OrderSummaryActionControllerTest {

    @IsTest
    private static void testDownloadMethod () {
        Test.startTest();

        List<B2B_OrderExcelConfig__c> listExcelConfigs = new List<B2B_OrderExcelConfig__c>();
        B2B_OrderExcelConfig__c obj1 = new B2B_OrderExcelConfig__c(Name='Sold To1', FieldName__c='B2B_SoldToParty__c', SortOrder__c=1, Type__c='Parent');
        listExcelConfigs.add(obj1);
        B2B_OrderExcelConfig__c obj2 = new B2B_OrderExcelConfig__c(Name='Ship To1', SortOrder__c=2);
        listExcelConfigs.add(obj2);
        B2B_OrderExcelConfig__c obj3 = new B2B_OrderExcelConfig__c(Name='PO Date1', FieldName__c='OrderedDate', SortOrder__c=3, Type__c='Parent', ColumnType__c='Date');
        listExcelConfigs.add(obj3);
        B2B_OrderExcelConfig__c obj4 = new B2B_OrderExcelConfig__c(Name='Pricing Date1', FieldName__c='OrderedDate', SortOrder__c=4, Type__c='Parent', ColumnType__c='Date');
        listExcelConfigs.add(obj4);
        B2B_OrderExcelConfig__c obj5 = new B2B_OrderExcelConfig__c(Name='PO Number1', FieldName__c='OrderNumber', SortOrder__c=5, Type__c='Parent');
        listExcelConfigs.add(obj5);
        B2B_OrderExcelConfig__c obj6 = new B2B_OrderExcelConfig__c(Name='Order Type1', FieldName__c='B2B_PlantName__c', SortOrder__c=6, Type__c='Child', MetaDataField__c='OrderType__c');
        listExcelConfigs.add(obj6);
        B2B_OrderExcelConfig__c obj7 = new B2B_OrderExcelConfig__c(Name='Plant1', FieldName__c='B2B_PlantName__c', SortOrder__c=7, Type__c='Child', MetaDataField__c='PlantCode__c');
        listExcelConfigs.add(obj7);
        B2B_OrderExcelConfig__c obj8 = new B2B_OrderExcelConfig__c(Name='Material1', FieldName__c='ProductCode', SortOrder__c=8, Type__c='Child');
        listExcelConfigs.add(obj8);
        B2B_OrderExcelConfig__c obj9 = new B2B_OrderExcelConfig__c(Name='Customer material no.1', FieldName__c='ProductCode', SortOrder__c=9, Type__c='Child');
        listExcelConfigs.add(obj9);
        B2B_OrderExcelConfig__c obj10 = new B2B_OrderExcelConfig__c(Name='Order Quantity1', FieldName__c='Quantity', SortOrder__c=10, Type__c='Child');
        listExcelConfigs.add(obj10);
        B2B_OrderExcelConfig__c obj11 = new B2B_OrderExcelConfig__c(Name='Special Price1', FieldName__c='UnitPrice', SortOrder__c=11, Type__c='Child', ShowCurrencyCode__c=true, ColumnType__c='Currency');
        listExcelConfigs.add(obj11);
        B2B_OrderExcelConfig__c obj12 = new B2B_OrderExcelConfig__c(Name='First Date1', SortOrder__c=12);
        listExcelConfigs.add(obj12);
        B2B_OrderExcelConfig__c obj13 = new B2B_OrderExcelConfig__c(Name='Business Process1', SortOrder__c=13);
        listExcelConfigs.add(obj13);
        B2B_OrderExcelConfig__c obj14 = new B2B_OrderExcelConfig__c(Name='Incoterm 21', FieldName__c='B2B_PlantName__c', SortOrder__c=14, Type__c='Child', MetaDataField__c='Incoterm2__c');
        listExcelConfigs.add(obj14);
        B2B_OrderExcelConfig__c obj15 = new B2B_OrderExcelConfig__c(Name='Storage Location1', SortOrder__c=15);
        listExcelConfigs.add(obj15);
        B2B_OrderExcelConfig__c obj16 = new B2B_OrderExcelConfig__c(Name='Shipping Type1', SortOrder__c=16);
        listExcelConfigs.add(obj16);
        B2B_OrderExcelConfig__c obj17 = new B2B_OrderExcelConfig__c(Name='Workflow Number1', SortOrder__c=17);
        listExcelConfigs.add(obj17);
        B2B_OrderExcelConfig__c obj18 = new B2B_OrderExcelConfig__c(Name='Lead Time (Weeks)1', FieldName__c='B2B_LeadTimeWeeks__c', SortOrder__c=18, Type__c='Child');
        listExcelConfigs.add(obj18);

        insert listExcelConfigs;

        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Order objOrder = new Order(
            AccountId = objAccount.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert objOrder;
        
        Product2 objProduct = new Product2(
            Name = 'Test Product',
            B2B_SEGIAMProductNumber__c = '1234'
        );
        insert objProduct;
        
        OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod(
            Name = 'Test'
        );
        insert objOrderDeliveryMethod;
        
        OrderDeliveryGroup objOrderDeliveryGroup = new OrderDeliveryGroup(
            DeliverToName = 'Test',
            OrderId = objOrder.Id,
            OrderDeliveryMethodId = objOrderDeliveryMethod.Id
        );
        insert objOrderDeliveryGroup;
        
        OrderItem objOrderProduct = new OrderItem(
            Product2Id = objProduct.Id,
            OrderId = objOrder.Id,
            UnitPrice = 15,
            Quantity = 21,
            ListPrice = 10,
            TotalLineAmount = 10,
            OrderDeliveryGroupId = objOrderDeliveryGroup.Id
        );
        insert objOrderProduct;
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        ConnectApi.OrderSummaryInputRepresentation objOrderSummaryInput = new ConnectApi.OrderSummaryInputRepresentation();
        objOrderSummaryInput.OrderId = objOrder.Id;
        objOrderSummaryInput.Status = 'Created';
        ConnectApi.OrderSummaryOutputRepresentation objOrderSummaryOutput = ConnectApi.OrderSummaryCreation.createOrderSummary(objOrderSummaryInput);

        B2B_OrderSummaryActionController.getDownloadActionDetails(objOrderSummaryOutput.OrderSummaryId);

        Test.stopTest();
    }


}