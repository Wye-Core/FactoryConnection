xmlport 50104 Epicor_SLImport
{
    Format = FixedText;
    //Direction = Import;
    TextEncoding = UTF8;
    TableSeparator = '<NewLine>';
    UseRequestPage = true;
    Description = 'Epicor SL Import';


    schema
    {

        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'Integer';
                SourceTableView = sorting(Number);
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                textelement(RecType)
                {
                    Width = 2;
                }
                textelement(dhbFiller)
                {
                    Width = 30;
                }
                textelement(GLAcctNo)
                {
                    Width = 16;
                }
                textelement(dhbFiller_2)
                {
                    Width = 1;
                }
                textelement(dhbDept)
                {
                    Width = 3;
                }
                textelement(dhbAmountTxt)
                {
                    width = 11;
                }
                textelement(dhbFiller_3)
                {
                    Width = 2;
                }

                textelement(JulianDate)
                {
                    Width = 5;
                }

                trigger OnBeforeInsertRecord()
                begin
                    IF (RecType = 'BH') OR (RecType = 'TH') THEN
                        CurrXMLport.SKIP;

                    GLAcctNo := DELCHR(GLAcctNo, '=', '');

                    IF (GLAcctNo = '100') THEN
                        CurrXMLport.SKIP;

                    IF dhbAmountTxt = '0' THEN
                        CurrXMLport.SKIP;


                    JulianDate := '20' + JulianDate;
                    EVALUATE(dhbYear, COPYSTR(JulianDate, 1, 4));
                    JulianDate := COPYSTR(JulianDate, 5, 3);
                    BeginYearDate := DMY2DATE(01, 01, dhbYear);
                    BeginYearDate := CALCDATE('-1D', BeginYearDate);
                    dhbPostingDate := CALCDATE(JulianDate + 'D', BeginYearDate);
                    dhbAmountTxt := DELCHR(dhbAmountTxt, '=', '');
                    dhbLen := STRLEN(dhbAmountTxt);
                    IF dhbLen = 0 THEN
                        CurrXMLport.SKIP;

                    dhbAmountTxt := INSSTR(dhbAmountTxt, '.', dhbLen - 1);

                    EVALUATE(dhbAmount, dhbAmountTxt);

                    CreatePurchJnl;
                end;

                trigger OnAfterInsertRecord()
                begin


                end;
            }
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Option';
                    field(DocumentNo; dhbDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        Tooltip = 'Specifies the Document No. Value for teh Import';
                    }
                }
            }
        }
    }
    var
        dhbLen: Integer;
        dhbDocNo: Code[20];
        dhbDescription: Text[50];
        //JulianDate: Text[20];
        dhbGLAcctNo: Code[20];
        dhbTempName: Code[20];
        dhbLocation: code[20];
        dhbDocType: Integer;
        dhbPayTerms: code[20];
        dhbInvDate: date;
        dhbDueDate: date;
        Vendor: Record "Vendor";
        dhbPayDiscDate: date;
        dhbBalAcctNo: code[20];
        dhbDoNotImport: Boolean;
        dhbPosition: integer;
        ISCounter: integer;
        NoMoreISRecs: boolean;
        dhbRemitToVendor: code[20];
        dhbBatchName: code[20];
        dhbLineNo: integer;
        dhbPos: Integer;
        dhbYear: Integer;
        dhbPostingDate: Date;
        dhbDay: Integer;
        dhbMonth: Integer;
        BeginYearDate: Date;
        dhbAmount: Decimal;



    local procedure CreatePurchJnl();
    var
        dhbGenJnlLine: Record "Gen. Journal Line";
    begin
        dhbGenJnlLine.INIT;
        dhbLineNo += 10000;
        dhbGenJnlLine."Journal Template Name" := dhbTempName;
        dhbGenJnlLine."Journal Batch Name" := dhbBatchName;
        dhbGenJnlLine."Line No." := dhbLineNo;
        dhbGenJnlLine."Posting Date" := dhbPostingDate;
        dhbGenJnlLine."Document No." := dhbDocNo;
        dhbGenJnlLine.VALIDATE("Account Type", dhbGenJnlLine."Account Type"::"G/L Account");
        dhbGenJnlLine.VALIDATE("Account No.", GLAcctNo);
        dhbGenJnlLine.VALIDATE("Shortcut Dimension 1 Code", dhbDept);
        dhbGenJnlLine.VALIDATE(Amount, dhbAmount);
        dhbGenJnlLine.Validate("Source Code", 'PURCHJNL');
        dhbGenJnlLine.INSERT;
    end;

    Procedure GetJnlInfo(TempName: Code[10]; BatchName: Code[20])
    var
        dhbGenJournalLine: record "Gen. Journal Line";
    begin
        dhbTempName := TempName;
        dhbBatchName := BatchName;

        dhbLineNo := 0;
        dhbGenJournalLine.RESET;
        dhbGenJournalLine.SETRANGE("Journal Template Name", dhbTempName);
        dhbGenJournalLine.SETRANGE("Journal Batch Name", dhbBatchName);
        IF dhbGenJournalLine.FIND('+') THEN
            dhbLineNo := dhbGenJournalLine."Line No.";
    end;
}