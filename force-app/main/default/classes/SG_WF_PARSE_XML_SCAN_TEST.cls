@isTest
public class SG_WF_PARSE_XML_SCAN_TEST {
    static testMethod void testpageandcontroller() {
        Scan__c scan = new Scan__c();
                   insert scan;
                    Attachment att = new Attachment();
                   att.ContentType = 'application/xml';
                   att.Body = Blob.valueOf('<DOCUMENT><FIELDGROUP Name="Header"><FIELD Name="INV_AMOUNT" Value="572.99"/><FIELD Name="INV_COMPLIANT" Value="TRUE"/><FIELD Name="INV_CREDIT_NOTE" Value="FALSE"/><FIELD Name="INV_CURRENCY" Value="EUR"/><FIELD Name="INV_NET_AMOUNT1" Value="572.99"/><FIELD Name="INV_NET_AMOUNT2" Value="0.00"/><FIELD Name="INV_NET_AMOUNT3" Value="0.00"/><FIELD Name="INV_NUMMER" Value="4038643"/><FIELD Name="INV_DATE" Value="20170406"/><FIELD Name="INV_TAX_AMOUNT1" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT2" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT3" Value="0.00"/><FIELD Name="INV_TAX_RATE1" Value="0.00"/><FIELD Name="INV_TAX_RATE2" Value="0.00"/><FIELD Name="INV_TAX_RATE3" Value="0.00"/><FIELD Name="VE_PBANKTYPE" Value="0.00"/><FIELD Name="INV_UNPL_DEL_AMOUNT" Value="0.00"/><FIELD Name="INV_UNPL_DEL_TAX_RATE" Value="0.000"/><FIELD Name="VE_VENDOR_NO" Value="25465"/><FIELD Name="RE_RECIPIENT_NO" Value="68C0"/></FIELDGROUP><TABLE Name="InvoiceItems"><ROW><FIELD Name="INVI_POS_NO" Value="1"/><FIELD Name="INVI_ORI_ARTICLE_NO" Value="1331250051"/><FIELD Name="INVI_ORI_DESCRIPTION" Value="HALTEFEDER"/><FIELD Name="INVI_QUANTITY" Value="48150.00"/><FIELD Name="INVI_QUANTITY_UNIT" Value="Pcs"/><FIELD Name="INVI_SINGLE_NET_PRICE" Value="11.900"/><FIELD Name="INVI_SINGLE_NET_PRUNIT" Value="1000"/><FIELD Name="INVI_TOTAL_NET_PRICE" Value="572.99"/></ROW></TABLE></DOCUMENT>');
                   att.Name = 'TestAttachment';
                   att.ParentId = scan.Id;
                   insert att;
        
        system.debug('in testpageandcontroller');
        PageReference pageRef = Page.SG_WF_PARSE_SCAN_XML_PAGE;
        system.debug('pageref: '+ pageref);
        Test.setCurrentPage(pageRef);
        scan = new Scan__c();
                   insert scan;
 
                   att = new Attachment();
                   att.ContentType = 'application/xml';
                   att.Body = Blob.valueOf('<DOCUMENT><FIELDGROUP Name="Header"><FIELD Name="INV_AMOUNT" Value="572.99"/><FIELD Name="INV_COMPLIANT" Value="TRUE"/><FIELD Name="INV_CREDIT_NOTE" Value="FALSE"/><FIELD Name="INV_CURRENCY" Value="EUR"/><FIELD Name="INV_NET_AMOUNT1" Value="572.99"/><FIELD Name="INV_NET_AMOUNT2" Value="0.00"/><FIELD Name="INV_NET_AMOUNT3" Value="0.00"/><FIELD Name="INV_NUMMER" Value="4038643"/><FIELD Name="INV_DATE" Value="20170406"/><FIELD Name="INV_TAX_AMOUNT1" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT2" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT3" Value="0.00"/><FIELD Name="INV_TAX_RATE1" Value="0.00"/><FIELD Name="INV_TAX_RATE2" Value="0.00"/><FIELD Name="INV_TAX_RATE3" Value="0.00"/><FIELD Name="VE_PBANKTYPE" Value="0.00"/><FIELD Name="INV_UNPL_DEL_AMOUNT" Value="0.00"/><FIELD Name="INV_UNPL_DEL_TAX_RATE" Value="0.000"/><FIELD Name="VE_VENDOR_NO" Value="25465"/><FIELD Name="RE_RECIPIENT_NO" Value="68C0"/></FIELDGROUP><TABLE Name="InvoiceItems"><ROW><FIELD Name="INVI_POS_NO" Value="1"/><FIELD Name="INVI_ORI_ARTICLE_NO" Value="1331250051"/><FIELD Name="INVI_ORI_DESCRIPTION" Value="HALTEFEDER"/><FIELD Name="INVI_QUANTITY" Value="48150.00"/><FIELD Name="INVI_QUANTITY_UNIT" Value="Pcs"/><FIELD Name="INVI_SINGLE_NET_PRICE" Value="11.900"/><FIELD Name="INVI_SINGLE_NET_PRUNIT" Value="1000"/><FIELD Name="INVI_TOTAL_NET_PRICE" Value="572.99"/></ROW></TABLE></DOCUMENT>');
                   att.Name = 'TestAttachment';
                   att.ParentId = scan.Id;
                   insert att;


        System.currentPageReference().getParameters().put('index', '1');

        SG_WF_PARSE_SCAN_XML contr = new SG_WF_PARSE_SCAN_XML(new ApexPages.StandardController(scan));
        
        
        //req.workflow_number__c = '01';
        //contr.populate();
        contr.sapCall();
        System.assertnotequals(scan.name,'S000000252', ' Name ' + scan.name);

        update att;
        contr.sapCall();
        System.assertnotequals(scan.Name,'S000000252', ' Name ' + scan.Name);
    }
    static testMethod void testpageandcontrollerUpdate() {
        Scan__c scan = new Scan__c();
        insert scan;
        Attachment att = new Attachment();
        att.ContentType = 'application/xml';
        att.Body = Blob.valueOf('<DOCUMENT><FIELDGROUP Name="Header"><FIELD Name="INV_AMOUNT" Value="572.99"/><FIELD Name="INV_COMPLIANT" Value="TRUE"/><FIELD Name="INV_CREDIT_NOTE" Value="FALSE"/><FIELD Name="INV_CURRENCY" Value="EUR"/><FIELD Name="INV_NET_AMOUNT1" Value="572.99"/><FIELD Name="INV_NET_AMOUNT2" Value="0.00"/><FIELD Name="INV_NET_AMOUNT3" Value="0.00"/><FIELD Name="INV_NUMMER" Value="4038643"/><FIELD Name="INV_DATE" Value="20170406"/><FIELD Name="INV_TAX_AMOUNT1" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT2" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT3" Value="0.00"/><FIELD Name="INV_TAX_RATE1" Value="0.00"/><FIELD Name="INV_TAX_RATE2" Value="0.00"/><FIELD Name="INV_TAX_RATE3" Value="0.00"/><FIELD Name="VE_PBANKTYPE" Value="0.00"/><FIELD Name="INV_UNPL_DEL_AMOUNT" Value="0.00"/><FIELD Name="INV_UNPL_DEL_TAX_RATE" Value="0.000"/><FIELD Name="VE_VENDOR_NO" Value="25465"/><FIELD Name="RE_RECIPIENT_NO" Value="68C0"/></FIELDGROUP><TABLE Name="InvoiceItems"><ROW><FIELD Name="INVI_POS_NO" Value="1"/><FIELD Name="INVI_ORI_ARTICLE_NO" Value="1331250051"/><FIELD Name="INVI_ORI_DESCRIPTION" Value="HALTEFEDER"/><FIELD Name="INVI_QUANTITY" Value="48150.00"/><FIELD Name="INVI_QUANTITY_UNIT" Value="Pcs"/><FIELD Name="INVI_SINGLE_NET_PRICE" Value="11.900"/><FIELD Name="INVI_SINGLE_NET_PRUNIT" Value="1000"/><FIELD Name="INVI_TOTAL_NET_PRICE" Value="572.99"/></ROW></TABLE></DOCUMENT>');
        att.Name = 'TestAttachment';
        att.ParentId = scan.Id;
        insert att;

        system.debug('in testpageandcontroller');
        PageReference pageRef = Page.SG_WF_PARSE_SCAN_XML_PAGE;
        system.debug('pageref: '+ pageref);
        Test.setCurrentPage(pageRef);
        
        update scan;

        //att.ContentType = 'application/xml';
        //att.Body = Blob.valueOf('<DOCUMENT><FIELDGROUP Name="Header"><FIELD Name="INV_AMOUNT" Value="572.99"/><FIELD Name="INV_COMPLIANT" Value="TRUE"/><FIELD Name="INV_CREDIT_NOTE" Value="FALSE"/><FIELD Name="INV_CURRENCY" Value="EUR"/><FIELD Name="INV_NET_AMOUNT1" Value="572.99"/><FIELD Name="INV_NET_AMOUNT2" Value="0.00"/><FIELD Name="INV_NET_AMOUNT3" Value="0.00"/><FIELD Name="INV_NUMMER" Value="4038643"/><FIELD Name="INV_DATE" Value="20170406"/><FIELD Name="INV_TAX_AMOUNT1" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT2" Value="0.00"/><FIELD Name="INV_TAX_AMOUNT3" Value="0.00"/><FIELD Name="INV_TAX_RATE1" Value="0.00"/><FIELD Name="INV_TAX_RATE2" Value="0.00"/><FIELD Name="INV_TAX_RATE3" Value="0.00"/><FIELD Name="VE_PBANKTYPE" Value="0.00"/><FIELD Name="INV_UNPL_DEL_AMOUNT" Value="0.00"/><FIELD Name="INV_UNPL_DEL_TAX_RATE" Value="0.000"/><FIELD Name="VE_VENDOR_NO" Value="25465"/><FIELD Name="RE_RECIPIENT_NO" Value="68C0"/></FIELDGROUP><TABLE Name="InvoiceItems"><ROW><FIELD Name="INVI_POS_NO" Value="1"/><FIELD Name="INVI_ORI_ARTICLE_NO" Value="1331250051"/><FIELD Name="INVI_ORI_DESCRIPTION" Value="HALTEFEDER"/><FIELD Name="INVI_QUANTITY" Value="48150.00"/><FIELD Name="INVI_QUANTITY_UNIT" Value="Pcs"/><FIELD Name="INVI_SINGLE_NET_PRICE" Value="11.900"/><FIELD Name="INVI_SINGLE_NET_PRUNIT" Value="1000"/><FIELD Name="INVI_TOTAL_NET_PRICE" Value="572.99"/></ROW></TABLE></DOCUMENT>');
        att.Name = 'TestAttachment';
        //att.ParentId = scan.Id;
        update att;


        System.currentPageReference().getParameters().put('index', '1');

        SG_WF_PARSE_SCAN_XML contr = new SG_WF_PARSE_SCAN_XML(new ApexPages.StandardController(scan));
        
        //req.workflow_number__c = '01';
        //contr.populate();
        contr.sapCall();
        System.assertnotequals(scan.name,'S000000252', ' Name ' + scan.name);


    }

}