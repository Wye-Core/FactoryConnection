xmlport 50106 GL_Import
{
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;


    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'Integer';
                SourceTableView = sorting(Number);
                AutoReplace = false;
                AutoUpdate = false;
                AutoSave = false;
                textelement(dhbPostingDatetxt) { }
                textelement(dhbDocumentNo) { }
                textelement(dhbAccountNo) { }
                textelement(dhbDepartmentCode) { }
                textelement(dhbDescription) { }
                textelement(dhbAmounttxt) { }
                //textelement(dhbBalAccountNo) { }


                trigger OnBeforeInsertRecord()
                begin

                    //dhbPostingDatetxt := '';
                    // dhbDocumentNo := '';
                    //dhbAccountNo := '';
                    //dhbDepartmentCode := '';
                    //dhbDescription := '';
                    // dhbAmounttxt := '';
                    //dhbBalAccountNo := '';
                    dhbLen := StrLen(dhbDepartmentCode);
                    IF dhbLen < 3 Then begin
                        for Cnt := 1 to 3 - dhbLen Do begin
                            dhbDepartmentCode := '0' + dhbDepartmentCode;
                        end;
                    end;

                end;

                trigger OnAfterInsertRecord()
                begin

                    Evaluate(dhbAmount, dhbAmounttxt);
                    Evaluate(dhbPostingDate, dhbPostingDatetxt);

                    IF (dhbAmount <> 0) AND (dhbAccountNo <> '') THEN BEGIN
                        dhbLineNo := dhbLineNo + 10000;
                        dhbGenJnlLine.INIT;
                        dhbGenJnlLine.VALIDATE("Journal Template Name", dhbJournalTemplate);
                        dhbGenJnlLine.VALIDATE("Journal Batch Name", dhbJournalBatch);
                        dhbGenJnlLine.VALIDATE("Line No.", dhbLineNo);
                        dhbGenJnlLine."Account Type" := dhbGenJnlLine."Account Type"::"G/L Account";
                        dhbGenJnlLine.VALIDATE("Account No.", dhbAccountNo);
                        dhbGenJnlLine.VALIDATE(Description, dhbDescription);
                        dhbGenJnlLine."Document Type" := dhbGenJnlLine."Document Type"::" ";
                        dhbGenJnlLine.VALIDATE("Document No.", dhbDocumentNo);
                        dhbGenJnlLine.VALIDATE("Posting Date", dhbPostingDate);
                        dhbGenJnlLine.VALIDATE(Amount, dhbAmount);
                        dhbGenJnlLine.VALIDATE("Shortcut Dimension 1 Code", dhbDepartmentCode);
                        dhbGenJnlLine.Validate("Source Code", 'GENJNL');
                        //IF (dhbBalAccountNo <> '') THEN BEGIN
                        //    dhbGenJnlLine."Bal. Account Type" := dhbGenJnlLine."Bal. Account Type"::"G/L Account";
                        //    dhbGenJnlLine.VALIDATE("Bal. Account No.", dhbBalAccountNo);
                        // END;
                        dhbGenJnlLine.INSERT;
                    END;
                end;


            }
        }
    }
    var
        dhbJournalTemplate: Code[10];
        dhbJournalbatch: Code[10];
        dhbLineNo: Integer;
        dhbGenJnlLine: Record "Gen. Journal Line";
        dhbAmount: Decimal;
        dhbPostingDate: Date;
        dhbLen: Integer;
        Cnt: Integer;

    procedure dhbPassVariables(dhbPassJournalTemplate: Code[10]; dhbPassJournalBatch: Code[10])
    begin
        dhbJournalTemplate := dhbPassJournalTemplate;
        dhbJournalBatch := dhbPassJournalBatch;
    end;



}