xmlport 50103 Epicor_SAImport
{
    Format = VariableText;
    //Direction = Import;
    TextEncoding = UTF8;
    //FieldSeparator = '<,>';
    tableSeparator = '<NewLine>';
    UseRequestPage = true;
    Description = 'Epicor SA Import';


    schema
    {

        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'Integer';
                SourceTableView = sorting(Number) Where(Number = const(1));
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                textelement(dhbFlag) { }
                textelement(dhbDescp) { }
                textelement(dhbSkip) { }
                textelement(dhbAcctDepCode) { }
                textelement(dhbAmount) { }
                textelement(dhbSkip2) { }
                textelement(dhbDateTxt) { }
                textelement(dhbSkip3) { }


                trigger OnBeforeInsertRecord()
                begin

                end;

                trigger OnAfterInsertRecord()
                begin
                    Case dhbFlag of
                        'BH':
                            begin
                                currXMLport.skip;
                            end;

                        'DT':
                            begin
                                if dhbAcctDepCode = '0' then Begin
                                    ClearVariables();
                                    currXMLport.Skip;
                                End Else begin
                                    dhbGLAcctNo := CopyStr(dhbAcctDepCode, 1, 4);
                                    dhbDept := copystr(dhbAcctDepCode, 5, MaxStrLen(dhbAcctDepCode));
                                end;

                                dhbLen := StrLen(dhbAmount);
                                IF dhbLen < 3 Then begin
                                    dhbPos := StrPos(dhbAmount, '-');
                                    IF dhbPos > 0 Then begin
                                        dhbAmount := InsStr(dhbAmount, '00', dhbPos + 1);
                                    end Else begin
                                        For Cnt := 1 to 2 Do begin
                                            dhbAmount := '0' + dhbAmount;
                                        end;
                                    end;
                                end;

                                dhbDateTxt := '20' + dhbDateTxt;
                                EVALUATE(dhbYear, COPYSTR(dhbdateTxt, 1, 4));
                                dhbDateTxt := COPYSTR(dhbDateTxt, 5, 3);
                                BeginYearDate := DMY2DATE(01, 01, dhbYear);
                                BeginYearDate := CALCDATE('-1D', BeginYearDate);
                                dhbPostingDate := CALCDATE(dhbDateTxt + 'D', BeginYearDate);

                                dhbLen := StrLen(dhbAmount);
                                dhbAmount := InsStr(dhbAmount, '.', dhbLen - 1);
                                Evaluate(dhbAmountDec, dhbAmount);
                                CreatePurchJnl();
                                ClearVariables();


                            end;
                        'TH':
                            begin
                                currXMLport.skip;
                            end;

                    End
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
        dhbWindow: Dialog;
        //dhbFlag: text[2];
        dhbLen: Integer;
        dhbfieldPos: integer;
        dhbDescription: Text[80];
        dhbDocNo: code[20];
        dhbVendNo: code[20];
        dhbAmountDec: decimal;
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
        Cnt: Integer;
        dhbDept: Code[20];



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
        dhbGenJnlLine.VALIDATE("Account No.", dhbGLAcctNo);
        dhbGenJnlLine.VALIDATE("Shortcut Dimension 1 Code", dhbDept);
        dhbGenJnlLine.VALIDATE(Amount, dhbAmountDec);
        dhbGenJnlLine.Validate("Source Code", 'PURCHJNL');
        dhbGenJnlLine.INSERT;
    end;

    local procedure ClearVariables();
    begin
        //dhbDocNo := '';
        dhbAmountDec := 0;
        dhbDept := '';
        dhbPostingDate := 0D;
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