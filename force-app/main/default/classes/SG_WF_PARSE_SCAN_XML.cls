/**
*
*
* @ Purpose : This Apex Class acts as an controller to parse the attached xml file
*
* @ Author: Peter Bosch
*
*
*       Date                |   Developer Name                  |   Version     |   Changes
* ===========================================================================================================
*   (1.0) 10.08.2017        |   Peter.Bosch@t-systems.com    |  1.0         |   Initial Version
*/



public class SG_WF_PARSE_SCAN_XML {
    public SG_WF_PARSE_SCAN_XML() {}
    public String xmlshow {get; set;}
    public String INV_BARCODE {get; set;}
    public String INV_AMOUNT_ROUNDING {get; set;}
    public String INV_AMOUNT {get; set;}
    public String INV_CREDIT_NOTE {get; set;}
    public String INV_DISCOUNT_AMOUNT1 {get; set;}
    public String INV_DISCOUNT_AMOUNT2 {get; set;}
    public String INV_DISCOUNT_PERCENT1 {get; set;}
    public String INV_DISCOUNT_PERCENT2 {get; set;}
    public String INV_IS_INTERCOMPANY {get;set;}
    public String INV_IS_MM {get;set;}
    public String INV_CURRENCY {get; set;}
    public String INV_NET_AMOUNT1 {get; set;}
    public String INV_NET_AMOUNT2 {get; set;}
    public String INV_NET_AMOUNT3 {get; set;}
    public String INV_NUMMER {get; set;}
    public String INV_DATE {get; set;}
    public String INV_TAX_AMOUNT1 {get; set;}
    public String INV_TAX_AMOUNT2 {get; set;}
    public String INV_TAX_AMOUNT3 {get; set;}
    public String INV_TAX_RATE1 {get; set;}
    public String INV_TAX_RATE2 {get; set;}
    public String INV_TAX_RATE3 {get; set;}
    public String INV_UNPL_DEL_AMOUNT {get; set;}
    public String INV_UNPL_DEL_TAX_RATE {get; set;}
    public String VE_VENDOR_NO {get; set;}
    public String RE_RECIEPIENT_NO {get; set;}
    public String VE_ACCOUNT_NO {get;set;}
    public String VE_PBANKTYPE {get;set;}
    
    
    public List<String> INVI_DISCOUNT_AMOUNT1 {get; set;}
    public List<String> INVI_DISCOUNT_AMOUNT2 {get; set;}
    public List<String> INVI_DISCOUNT_AMOUNT3 {get; set;}
    Public List<String> INVI_DISCOUNT_PERCENT1 {get;set;}
    public List<String> INVI_DISCOUNT_PERCENT2 {get;set;}
    public List<String> INVI_DISCOUNT_PERCENT3 {get;set;}
    public List<String> INVI_POS_NO {get; set;}
    public List<String> INVI_ORDER_NO {get;set;}
    public List<String> INVI_ORI_ARTICLE_NO {get; set;}
    public List<String> INVI_ORI_DESCRIPTION {get; set;}
    public List<String> INVI_QUANTITY {get; set;}
    public List<String> INVI_QUANTITY_UNIT {get; set;}
    public List<String> INVI_SINGLE_NET_PRICE {get; set;}
    public List<String> INVI_SINGLE_NET_PRUNIT {get; set;}
    // #### Real Name of INVI_SINGLE_NET_PER_UNIT
    public List<String> INVI_SINGLE_NET_PER_UNIT {get;set;}
    public List<String> INVI_TOTAL_NET_PRICE {get; set;}

    public final scan__c scan;
    public final scan__c sc;
    // ApexPages.StandardController sc;
    private final attachment atm;
    Public Dom.Document doc;
    public string sfIdInClass {get;set;}
    public String strXmlContainer{get;set;}
    String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    String xsi = 'http://www.w3.org/2001/XMLSchema-instance';

       
    public SG_WF_PARSE_SCAN_XML(ApexPages.StandardController stdController) {
        this.scan = (Scan__c)stdController.getRecord();
        this.sc = (Scan__c)stdController.getRecord();
        System.debug('Initializing stdcontr: ' + ApexPages.currentPage().getParameters().get('id') + ' - ' + scan);
        for(Attachment atm: [SELECT Body,BodyLength,ContentType,Description,Id,Name,ParentId,SystemModstamp FROM Attachment where ContentType = 'application/xml' and parentId  = :scan.Id])
        {
            System.debug('Attachment Id and name: ' + atm.Id + ' - ' + atm.name);
                   
            System.debug('XML Raw Data: ' + EncodingUtil.base64encode(atm.body));
            Dom.Document doc = new Dom.Document();
            Blob b = EncodingUtil.base64Decode(EncodingUtil.base64encode(atm.body));
            System.debug('Blob to String: ' + b.toString());
            System.debug('xmlshow field');
            doc.load(b.toString()); 
            System.debug('docload done');
            Dom.XMLNode env= doc.getRootElement();
            system.debug('root : '+ env.getname());
            Dom.XmlNode node = doc.getRootElement().getChildElement('FIELDGROUP', null) ;
            String a1 = node.getname();
            dom.XmlNode SFNode = env.addChildElement('FIELDGROUP' , null, null);
            dom.XmlNode SFChild = SFNode.addChildElement('FIELD Name = "SF_ID" Value ="' + scan.Name +'"', null, null);
            SFnode.setAttribute('NAME', 'SALESFORCE');
            //SFChild.setAttribute('SF_SAMPLE_ATTRIB', '12345678');
            system.debug('getname child1 attribute=' +a1 );
            xmlshow = doc.toXmlString();
            for (Dom.XmlNode child1 :  node.getChildElements() ) {
                    String c1 = child1.getname();
                    String c11 = child1.gettext();
                if (child1.getAttributeValue('Name','') == 'INV_AMOUNT' ) {INV_AMOUNT = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_CURRENCY' ) {INV_CURRENCY = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_NET_AMOUNT1' ) {INV_NET_AMOUNT1 = child1.getAttributeValue('Value','');} 
                if (child1.getAttributeValue('Name','') == 'INV_NET_AMOUNT2' ) {INV_NET_AMOUNT2 = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_NET_AMOUNT3' ) {INV_NET_AMOUNT3 = child1.getAttributeValue('Value','');} 
                if (child1.getAttributeValue('Name','') == 'INV_NUMMER' ) {INV_NUMMER = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_DATE' ) {INV_DATE = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_TAX_AMOUNT1' ) {INV_TAX_AMOUNT1 = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_TAX_AMOUNT2' ) {INV_TAX_AMOUNT2 = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_TAX_AMOUNT3' ) {INV_TAX_AMOUNT3 = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_TAX_RATE1' ) {INV_TAX_RATE1 = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_TAX_RATE2' ) {INV_TAX_RATE2 = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_TAX_RATE3' ) {INV_TAX_RATE3 = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_UNPL_DEL_AMOUNT' ) {INV_UNPL_DEL_AMOUNT = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'INV_UNPL_DEL_TAX_RATE' ) {INV_UNPL_DEL_TAX_RATE = child1.getAttributeValue('Value','');}                                                             
                if (child1.getAttributeValue('Name','') == 'VE_VENDOR_NO' ) {VE_VENDOR_NO = child1.getAttributeValue('Value','');}                                                            
                if (child1.getAttributeValue('Name','') == 'INV_BARCODE' ) {INV_BARCODE = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_AMOUNT_ROUNDING' ){INV_AMOUNT_ROUNDING = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_CREDIT_NOTE' ) {INV_CREDIT_NOTE = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_DISCOUNT_AMOUNT1' ) {INV_DISCOUNT_AMOUNT1 = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_DISCOUNT_AMOUNT2' ) {INV_DISCOUNT_AMOUNT2 = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_DISCOUNT_PERCENT1' ) {INV_DISCOUNT_PERCENT1 = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_DISCOUNT_PERCENT2' ) {INV_DISCOUNT_PERCENT2 = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_IS_INTERCOMPANY' ) {INV_IS_INTERCOMPANY = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'INV_IS_MM' ) {INV_IS_MM = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'RE_RECIEPIENT_NO' ) {RE_RECIEPIENT_NO = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'VE_ACCOUNT_NO' ) {VE_ACCOUNT_NO = child1.getAttributeValue('Value','');}
                if (child1.getAttributeValue('Name','') == 'VE_PBANKTYPE' ) {VE_PBANKTYPE = child1.getAttributeValue('Value','');}
                                                                                                                                                                       
                system.debug('gettext child1 attributegetname = '+c1 + ' value=' + c11 + ' getattrib ' + child1.getAttributeValue('Value','') + ' getname ' + child1.getAttributeValue('Name',''));
                        
            }
        
            Dom.XmlNode tnode = doc.getRootElement().getChildElement('TABLE', null).getchildelement('ROW', null) ;
            String ta1 = tnode.getname();
            
            system.debug('getname child1 mit Table attribute=' +ta1 );
            for (Dom.XmlNode tchild1 :  tnode.getChildElements() ) {
                system.debug('tchild1.getAttributeValue = '  + tchild1.getAttributeValue('Name','')); 
                if (tchild1.getAttributeValue('Name','') == 'INVI_POS_NO' ) {INVI_POS_NO = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_ORI_ARTICLE_NO' ) {INVI_ORI_ARTICLE_NO = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_ORI_DESCRIPTION' ) {INVI_ORI_DESCRIPTION = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_QUANTITY' ) {INVI_QUANTITY = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_QUANTITY_UNIT' ) {INVI_QUANTITY_UNIT = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_SINGLE_NET_PRICE' ) {INVI_SINGLE_NET_PRICE = new list<String> {tchild1.getAttributeValue('Value','')};}
                //if (tchild1.getAttributeValue('Name','') == 'INVI_SINGLE_NET_PRUNIT' ) {INVI_SINGLE_NET_PRUNIT = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_DISCOUNT_AMOUNT1' ) {INVI_DISCOUNT_AMOUNT1 = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_DISCOUNT_AMOUNT2' ) {INVI_DISCOUNT_AMOUNT2 = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_DISCOUNT_AMOUNT3' ) {INVI_DISCOUNT_AMOUNT3 = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_DISCOUNT_PERCENT1' ) {INVI_DISCOUNT_PERCENT1 = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_DISCOUNT_PERCENT2' ) {INVI_DISCOUNT_PERCENT2 = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_DISCOUNT_PERCENT3' ) {INVI_DISCOUNT_PERCENT3 = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_ORDER_NO' ) {INVI_ORDER_NO = new list<String> {tchild1.getAttributeValue('Value','')};}
                if (tchild1.getAttributeValue('Name','') == 'INVI_SINGLE_NET_PER_UNIT' ) {INVI_SINGLE_NET_PER_UNIT = new list<String> {tchild1.getAttributeValue('Value','')};}
                system.debug('gettext Tchild1 attributegetname = '+ta1  + ' getattribtable ' + tchild1.getAttributeValue('Value','') + ' getnametable ' + tchild1.getAttributeValue('Name',''));
                //system.debug('size pos no table = '+ INVI_POS_NO.size()); 
            }
            strXmlContainer = doc.toXmlString();
            scan.XML_Store__c = doc.toXmlString();
            sc.XML_Store__c = doc.toXmlString();
            //update sc;
           
                  }
       
            
    }
    
    
    public List<Integer> getIndexes() {
        system.debug('in list = ');
        List<Integer> indexes = new List<Integer>();
        system.debug('inpublic list = '+ INVI_POS_NO.size());
        
        if (INVI_POS_NO.size() > 0 ) {
            for (Integer i = 0; i < this.INVI_POS_NO.size(); i++) indexes.add(i);
        }
                return indexes;
    }
    public void populate(){
        
        System.debug('update scan ' + scan);
        scan.Barcode__c =   INV_BARCODE;
        scan.Salesforce_ID__c = scan.name;
        scan.Company_Code__c = VE_VENDOR_NO;
        
        
        update scan; 
            }

        // send xml to sap sopa endpoint https://ews-emea.api.bosch.com/apmr/v1.1  KeyId=5ead0f5a-d007-4e20-8706-b557251b38b7 xml in doc.toXmlString();
        public void write(){
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            if (!String.isEmpty(strXmlContainer)){
                System.debug('Got into the String Condition');
                req.setEndpoint('https://ews-emea.api.bosch.com/apmr/q/');
                req.setHeader('KeyId', Label.SAP_Key_Id);
                req.setHeader('SOAPAction', '""');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'text/xml');
                req.setBody(strXmlContainer);
                system.debug(req);
                System.debug('End String Condition');
                try {
                    res = http.send(req);
                    System.debug('Request Sent');
                    System.Debug(res.getStatus());
                } catch(System.CalloutException e) {
                    System.debug('Callout error: '+ e);
                    System.debug(res.getBody());
                }
            }
            
        } 

        public void sapCall(){
            Integer index = 0;
            SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInHeader header = new SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInHeader();
            header.IvBarcode = '68C0999999';
            header.IvAmount = INV_AMOUNT;
            header.IvAmtRound = INV_AMOUNT_ROUNDING;
            header.IvCreditNote = INV_CREDIT_NOTE;
            header.IvCurrency = INV_CURRENCY;
            header.IvDate = INV_DATE;
            header.IvDisAmt1 = INV_DISCOUNT_AMOUNT1;
            header.IvDisAmt2 = INV_DISCOUNT_AMOUNT2 ;
            header.IvDisPer1 = INV_DISCOUNT_PERCENT1;
            header.IvDisPer2 = INV_DISCOUNT_PERCENT2 ;
            header.IvIsIncomp = INV_IS_INTERCOMPANY;
            header.IvIsMm = INV_IS_MM;
            header.IvNetAmt1 = INV_NET_AMOUNT1;
            header.IvNetAmt2 = INV_NET_AMOUNT2;
            header.IvNetAmt3 = INV_NET_AMOUNT3;
            header.IvNumber = INV_NUMMER;
            header.IvTaxAmt1 = INV_TAX_AMOUNT1;
            header.IvTaxAmt2 = INV_TAX_AMOUNT2;
            header.IvTaxAmt3 = INV_TAX_AMOUNT3;
            header.IvTaxRate1 = INV_TAX_RATE1;
            header.IvTaxRate2 = INV_TAX_RATE2;
            header.IvTaxRate3 = INV_TAX_RATE3;
            header.IvUnplDelAmt = INV_UNPL_DEL_AMOUNT;
            header.IvUnplDelTax = INV_UNPL_DEL_TAX_RATE;
            header.ReRecipientNo = RE_RECIEPIENT_NO;
            header.VeAccountNo = '97183693';
            header.VePbanktype = VE_PBANKTYPE;
            System.Debug('\n' +INV_AMOUNT + '\n' +INV_AMOUNT + '\n' +INV_AMOUNT_ROUNDING + '\n' +INV_CREDIT_NOTE + '\n' +INV_CURRENCY + '\n' +INV_DATE 
                         + '\n' +INV_DISCOUNT_AMOUNT1  + '\n' +INV_DISCOUNT_AMOUNT2  + '\n' +INV_DISCOUNT_PERCENT1  + '\n' +INV_DISCOUNT_PERCENT2
                         + '\n' +INV_IS_INTERCOMPANY + '\n' +INV_IS_MM + '\n' +INV_NET_AMOUNT1 + '\n' +INV_NET_AMOUNT2 + '\n' +INV_NET_AMOUNT3 
                         + '\n' +INV_NUMMER + '\n' +INV_TAX_AMOUNT1  + '\n' +INV_TAX_AMOUNT2  + '\n' +INV_TAX_AMOUNT3  + '\n' +INV_UNPL_DEL_AMOUNT  
                         + '\n' +INV_UNPL_DEL_TAX_RATE + '\n' +RE_RECIEPIENT_NO + '\n' +VE_ACCOUNT_NO + '\n' +VE_PBANKTYPE);
            SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInInvT invoice = new SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInInvT();
            System.Debug('----> invoice '+ invoice);
            //populate invoice fields from scan object xml file
            List<SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInInv> invoiceItemList = new List<SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInInv>();
            for(Attachment atm: [SELECT Body,BodyLength,ContentType,Description,Id,Name,ParentId,SystemModstamp 
                                 FROM Attachment where ContentType = 'application/xml' and parentId  = :scan.Id]){
                Dom.Document doc = new Dom.Document();
                Blob b = EncodingUtil.base64Decode(EncodingUtil.base64encode(atm.body));
                doc.load(b.toString()); 
                Dom.XMLNode env= doc.getRootElement();
                Dom.XmlNode node = doc.getRootElement().getChildElement('FIELDGROUP', null) ;
                String a1 = node.getname();
                dom.XmlNode SFNode = env.addChildElement('FIELDGROUP' , null, null);
                dom.XmlNode SFChild = SFNode.addChildElement('FIELD Name = "SF_ID" Value ="' + scan.Name +'"', null, null);
                SFnode.setAttribute('NAME', 'SALESFORCE');
                SFChild.setAttribute('SF_SAMPLE_ATTRIB', '12345678');
                xmlshow = doc.toXmlString();
                Dom.XmlNode tnode = doc.getRootElement().getChildElement('TABLE', null);
                
                
                    System.debug('MSWIST DEBUG: '+tnode.getChildElements());
                    for(Dom.XmlNode tchild1 :  tnode.getchildelements()){
                        SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInInv invoiceItem = new SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInInv();
                        index +=1;
                        System.debug('Index: '+index);
                        for(Dom.XmlNode tchild2 : tchild1.getchildelements()){
                            if (tchild2.getAttributeValue('Name','') == 'INVI_DISCOUNT_AMOUNT1' ) {
                                invoiceItem.IvDisAmt1 = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvDisAmt1);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_DISCOUNT_AMOUNT2' ) {
                                invoiceItem.IvDisAmt2 = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvDisAmt2);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_DISCOUNT_AMOUNT3' ) {
                                invoiceItem.IvDisAmt3 = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvDisAmt3);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_DISCOUNT_PERCENT1' ) {
                                invoiceItem.IvDisPer1 = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvDisPer1);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_DISCOUNT_PERCENT2' ) {
                                invoiceItem.IvDisPer2 = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvDisPer2);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_DISCOUNT_PERCENT3' ) {
                                invoiceItem.IvDisPer3 = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvDisPer3);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_ORDER_NO' ) {
                                invoiceItem.IvOrderNo = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvOrderNo);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_POS_NO' ) {
                                invoiceItem.IvPosNo = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvPosNo);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_ORI_ARTICLE_NO' ) {
                                invoiceItem.IvOriArticleNo = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvOriArticleNo);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_ORI_DESCRIPTION' ) {
                                invoiceItem.IvOriDesc = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvOriDesc);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_QUANTITY' ) {
                                invoiceItem.IvQuantity = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvQuantity);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_QUANTITY_UNIT' ) {
                                //invoiceItem.IvUnit = 'PC';
                                invoiceItem.IvUnit = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvUnit);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_SINGLE_NET_PRICE' ) {
                                invoiceItem.IvSinglePrice = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvSinglePrice);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_PRICE_PER_UNIT' ) {
                                invoiceItem.IvPriceUnit = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvPriceUnit);
                            }
                            if (tchild2.getAttributeValue('Name','') == 'INVI_TOTAL_NET_PRICE' ) {
                                invoiceItem.IvTotalPrice = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvTotalPrice);
                            }
                            /**if (tchild2.getAttributeValue('Name','') == 'INVI_TAX_RATE' ) {
                                invoiceItem.IvTaxRate = tchild2.getAttributeValue('Value','');
                                System.Debug(invoiceItem.IvTaxRate);
                            }*/
                            System.debug('---> '+ invoiceItem);
                        }
                        invoiceItemList.add(invoiceItem);  
                    }        
                    invoice.item = invoiceItemList;
            }
            
            SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInSf sfId = new SG_WF_WS_Sap_Interface_MC_Style.ZmmSApmInSf();
            //populate with sfId
            sfId.sfId = scan.Id;
            SG_WF_WS_Sap_Interface_MC_Style.ZMM_APM_XML_BINDING stub = new SG_WF_WS_Sap_Interface_MC_Style.ZMM_APM_XML_BINDING(false);

            Map<String,String> headersMap = new Map<String, String>();
            headersMap.put('KeyId', Label.SAP_Key_Id);
            stub.inputHttpHeaders_x = headersMap;
            try {
                SG_WF_WS_Sap_Interface_MC_Style.ZMmApiXmlrespProviderResponse_element response = stub.ZMmApiXmlrespProvider(header, invoice, sfId);
            } catch (Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
            
        }          
   }