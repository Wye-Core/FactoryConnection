xmlport 50100 IMATImport
{
    Format = VariableText;
    //Direction = Import;
    TextEncoding = UTF8;
    FieldSeparator = '<TAB>';
    FieldDelimiter = '"';
    //TableSeparator = '<NewLine>';
    RecordSeparator = '<NewLine>';



    UseRequestPage = false;

    schema
    {

        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'Integer';
                SourceTableView = sorting(Number);
                RequestFilterFields = Number;
                AutoReplace = false;
                AutoUpdate = false;
                AutoSave = false;

                textelement(dhbFlag) { }
                textelement(dhbSkip) { }
                textelement(ExtDocNo) { }
                textelement(dhbCode) { }
                textelement(DocType) { }
                textelement(dhbSkip1) { }
                textelement(dhbSkip2) { }
                textelement(dhbSkip3) { }
                textelement(InvDate) { }
                textelement(dhbAmountTxt) { }
                textelement(dhbCode2) { }
                textelement(dhbSkip4) { }
                textelement(dhbSkip5) { }
                textelement(dhbSkip6) { }
                textelement(dhbSkip7) { }
                textelement(DueDate) { }
                textelement(dhbDiscDate) { }
                textelement(dhbSkip8) { }
                textelement(dhbSkip9) { }
                textelement(dhbVendNo) { }
                textelement(dhbSkip10) { }
                textelement(dhbSkip11) { }
                textelement(dhbSkip12) { }
                textelement(dhbSkip13) { }
                textelement(dhbSkip14) { }
                textelement(dhbSkip15) { }
                // textelement(dhbSkip16) { }
                // textelement(PayTerms) { }
                // textelement(dhbSkip17) { }



                trigger OnBeforeInsertRecord()
                begin
                    dhbPurchSetup.Get('');
                end;

                trigger OnAfterInsertRecord()
                begin

                    CASE dhbFlag OF
                        'IH':
                            BEGIN
                                dhbCreateJnl := TRUE;
                                dhbFieldPos += 1;
                                dhbExtDocNo := ExtDocNo;
                                VendorNo := '';
                                CASE DocType OF
                                    '20':
                                        dhbDocType := 2;  //Invoice
                                    '22':
                                        dhbDocType := 3; //Credit Memo
                                    '21':
                                        dhbDocType := 3; //Credit Memo
                                    '23':
                                        dhbDocType := 3; //Credit Memo

                                END;

                                iSDocType := dhbDocType;
                                EVALUATE(dhbInvDate, InvDate);
                                EVALUATE(dhbAmount, dhbAmountTxt);
                                EVALUATE(dhbDueDate, DueDate);
                                EVALUATE(dhbPayDiscDate, dhbDiscDate);
                                dhbLen := StrLen(dhbVendNo);
                                IF dhbLen < 6 then begin
                                    For cnt := 1 to 6 - dhbLen Do begin
                                        dhbVendNo := '0' + dhbVendNo;
                                    end;
                                end;

                                Vendor.SETFILTER("WDC Vendor Number", dhbVendNo);
                                IF Vendor.FIND('-') THEN
                                    VendorNo := Vendor."No."
                                ELSE
                                    ERROR('WDC Vendor No. %1 does not exist', dhbVendNo);
                                //Message('WDC %1\Vend no %2', Vendor."WDC Vendor Number", dhbVendNo);
                                //IF PayTerms <> '' Then
                                // dhbPayTerms := PayTerms;
                            END;

                        'IR':
                            BEGIN
                                dhbDocNo := dhbCode;
                                //currXMLport.skip;
                                dhbDocNo := dhbCode;
                                dhbLocation := DocType;


                            END;

                        'IS':
                            BEGIN
                                dhbFieldPos += 1;
                                EVALUATE(dhbInvDate, ExtDocNo);
                                IF NoMoreISRecs = FALSE THEN BEGIN
                                    dhbPosition := STRPOS(dhbCode, '-');
                                    IF dhbPosition > 0 THEN
                                        dhbBalAcctNo := COPYSTR(dhbCode, 1, dhbPosition - 1)
                                    ELSE
                                        dhbBalAcctNo := dhbCode;
                                END;

                                IF (isDocType = 2) AND (dhbCode2 = '1') THEN BEGIN
                                    NoMoreISRecs := TRUE;
                                END;
                                IF (isDocType = 2) AND (dhbCode2 = '-1') AND (dhbAmountTxt <> '0') THEN BEGIN
                                    NoMoreISRecs := TRUE;
                                    dhbPosition := STRPOS(dhbCode, '-');
                                    IF dhbPosition > 0 THEN
                                        dhbBalAcctNo := COPYSTR(dhbCode, 1, dhbPosition - 1)
                                    ELSE
                                        dhbBalAcctNo := dhbCode;
                                    CurrXMLport.SKIP;
                                END;

                                IF (isDocType = 3) AND (dhbCode2 = '1') THEN BEGIN
                                    CurrXMLport.SKIP;
                                END;
                                IF (isDocType = 3) AND (dhbCode2 = '-1') AND (dhbAmountTxt <> '0') THEN BEGIN
                                    NoMoreISRecs := TRUE;
                                END;
                            END;

                        'II':
                            BEGIN
                                NoMoreISRecs := FALSE;
                                IF (dhbCreateJnl = TRUE) THEN BEGIN
                                    CreatePurchJnl;
                                    ClearVariables;
                                    dhbCreateJnl := FALSE;
                                END;

                            END;
                    END;
                end;

            }
        }
    }
    var
        //dhbFlag: text[2];
        dhbfieldPos: integer;
        dhbDocNo: code[20];
        //dhbVendNo: code[20];
        dhbAmount: decimal;
        dhbLocation: code[20];
        dhbDocType: Integer;
        dhbPayTerms: code[20];
        dhbInvDate: date;
        dhbDueDate: date;
        dhbLen: Integer;
        cnt: Integer;
        Vendor: Record "Vendor";
        dhbPayDiscDate: date;
        dhbBalAcctNo: code[20];
        dhbPosition: integer;
        ISCounter: integer;
        NoMoreISRecs: boolean;
        dhbRemitToVendor: code[20];
        dhbTempName: code[20];
        dhbBatchName: code[20];
        dhbLineNo: integer;
        dhbExtDocNo: code[20];
        dhbCreateJnl: boolean;
        isDocType: Integer;
        VendorNo: Code[20];
        dhbPurchSetup: Record "Purchases & Payables Setup";



    local procedure CreatePurchJnl();
    var
        dhbPurchJnlLine: Record "Gen. Journal Line";
    begin

        dhbPurchJnlLine.INIT;
        dhbLineNo += 10000;
        dhbPurchJnlLine."Journal Template Name" := dhbTempName;
        dhbPurchJnlLine."Journal Batch Name" := dhbBatchName;
        dhbPurchJnlLine."Line No." := dhbLineNo;
        dhbPurchJnlLine."Posting Date" := dhbInvDate;
        dhbPurchJnlLine.VALIDATE("Document Type", dhbDocType);
        dhbPurchJnlLine."Document No." := INCSTR(dhbPurchSetup."IMAT Document No.");
        dhbPurchSetup."IMAT Document No." := dhbPurchJnlLine."Document No.";
        dhbPurchSetup.MODIFY;
        dhbPurchJnlLine."External Document No." := dhbExtDocNo;
        dhbPurchJnlLine.VALIDATE("Account Type", dhbPurchJnlLine."Account Type"::Vendor);
        dhbPurchJnlLine.VALIDATE("Account No.", VendorNo);
        dhbPurchJnlLine.VALIDATE(Amount, dhbAmount * -1);
        IF dhbDocType = 2 THEN BEGIN //invoice
            dhbPurchJnlLine.VALIDATE("Payment Terms Code", dhbPayTerms);
            dhbPurchJnlLine."Pmt. Discount Date" := dhbPayDiscDate;
        END;
        dhbPurchJnlLine."Due Date" := dhbDueDate;
        dhbPurchJnlLine.VALIDATE("Bal. Account Type", dhbPurchJnlLine."Bal. Account Type"::"G/L Account");
        dhbPurchJnlLine.VALIDATE("Bal. Account No.", dhbBalAcctNo);
        dhbPurchJnlLine.Validate("Source Code", 'PURCHJNL');
        dhbPurchJnlLine.INSERT(TRUE);
    end;

    local procedure ClearVariables();
    begin
        dhbDocNo := '';
        dhbVendNo := '';
        dhbAmount := 0;
        dhbLocation := '';
        dhbPayTerms := '';
        dhbDocType := 0;
        dhbInvDate := 0D;
        dhbDueDate := 0D;
        dhbPayDiscDate := 0D;
        dhbBalAcctNo := '';
        dhbPosition := 0;
        ISCounter := 0;
        dhbRemitToVendor := '';
        dhbExtDocNo := '';
    end;

    Procedure GetJnlInfo(TempName: Code[10]; BatchName: Code[20])
    var
        dhbPurchJournalLine: record "Gen. Journal Line";
    begin
        dhbTempName := TempName;
        dhbBatchName := BatchName;

        dhbLineNo := 0;
        dhbPurchJournalLine.RESET;
        dhbPurchJournalLine.SETRANGE("Journal Template Name", dhbTempName);
        dhbPurchJournalLine.SETRANGE("Journal Batch Name", dhbBatchName);
        IF dhbPurchJournalLine.FIND('+') THEN
            dhbLineNo := dhbPurchJournalLine."Line No.";
    end;

}

pageextension 50105 PurchJnlExt extends "Purchase Journal"
{

    actions
    {
        addafter(IncomingDocument)
        {
            action(IMATImport)
            {
                Caption = 'IMAT Import';
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                begin

                    CLEAR(dhbIMATImport);
                    dhbIMATImport.GetJnlInfo(Rec."Journal Template Name", Rec."Journal Batch Name");
                    dhbIMATImport.Run();
                    //Xmlport.Run(50100, true, false);

                    CurrPage.Update();
                end;
            }
        }

    }
    var
        dhbIMATImport: XmlPort IMATImport;

}