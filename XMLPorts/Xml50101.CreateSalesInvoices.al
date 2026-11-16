xmlport 50101 CreateSalesInvoices
{
    Caption = 'Import Sales Invoices';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    //FieldSeparator = '<,>';
    tableSeparator = '<NewLine>';
    UseRequestPage = true;
    Permissions = tabledata "No. Series Line" = rm;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(Integer; "Integer")
            {
                XmlName = 'Integer';
                SourceTableView = sorting(Number) Where(Number = const(1));
                RequestFilterFields = Number;
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                textelement(dhbPostingDateTxt) { }
                textelement(dhbTypeTxt) { }
                textelement(dhbItemNo) { }
                textelement(dhbCustNoTxt) { }
                textelement(dhbQtyTxt) { }

                trigger OnBeforeInsertRecord()
                begin

                    dhbPos := Strpos(dhbPostingDateTxt, '/');
                    IF dhbPos = 2 then
                        dhbPostingDateTxt := '0' + dhbPostingDateTxt;

                    dhbMonthTxt := COPYSTR(dhbPostingDateTxt, 4, 2);
                    dhbMonthTxt := DelChr(dhbMonthTxt, '=', '/');
                    dhbPos := StrLen(dhbMonthTxt);
                    IF dhbPos = 1 then
                        dhbMonthTxt := '0' + dhbMonthTxt;

                    dhbDayTxt := COPYSTR(dhbPostingDateTxt, 1, 2);
                    dhbDayTxt := DelChr(dhbDayTxt, '=', '/');
                    dhbPos := StrLen(dhbDayTxt);
                    IF dhbPos = 1 then
                        dhbDayTxt := '0' + dhbDayTxt;

                    dhbYearTxt := COPYSTR(dhbPostingDateTxt, 7, 4);
                    dhbPos := Strlen(dhbYearTxt);
                    IF dhbPos = 2 then
                        dhbYearTxt := '20' + dhbYeartxt;

                    IF dhbPos = 3 then
                        dhbYearTxt := '2' + dhbYeartxt;

                    EVALUATE(dhbYear, dhbYearTxt);


                    EVALUATE(dhbMonth, dhbMonthTxt);
                    EVALUATE(dhbDay, dhbDayTxt);

                    PostingDate := DMY2DATE(dhbMonth, dhbDay, dhbYear);

                    Evaluate(dhbQty, dhbQtyTxt);

                    dhbPos := StrLen(dhbCustNoTxt);
                    If dhbPos < 3 Then begin
                        For Cnt := 1 to 3 - dhbPos Do begin
                            dhbCustNoTxt := '0' + dhbCustNoTxt;
                        end;
                    end;
                    dhbCustNo := dhbCustNoTxt;

                    IF dhbXRecCustNo <> dhbCustNo Then Begin
                        dhbInvNo := IncStr(dhbInvNo);
                        SalesHeader.INIT;
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
                        SalesHeader.Validate("No.", dhbInvNo);
                        SalesHeader.Validate(SalesHeader."Sell-to Customer No.", dhbCustNo);
                        SalesHeader.Validate("Posting Date", PostingDate);
                        SalesHeader.Validate("Document Date", PostingDate);
                        SalesHeader.Insert();
                        SalesHeader.Validate("Shortcut Dimension 1 Code", dhbCustNo);
                        SalesHeader.Modify;
                        dhbXRecCustNo := dhbCustNo;
                        dhbLineNo := 0;

                    end;

                    SalesLine.Init();
                    dhbLineNo += 10000;
                    SalesLine."Line No." := dhbLineNo;
                    SalesLine.Validate("Document Type", SalesLine."Document Type"::Invoice);
                    SalesLine.Validate("Document No.", SalesHeader."No.");
                    SalesLine.Validate(Type, SalesLine.Type::Item); //Item
                    SalesLine.Validate("No.", dhbItemNo);
                    SalesLine.Validate(Quantity, dhbQty);
                    SalesLine.Insert;



                end;

                trigger OnAfterInsertRecord()
                begin


                end;

            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }

    }
    trigger OnPreXmlPort()
    begin
        NoSeriesLine.Setfilter(NoSeriesLine."Series Code", '=%1', 'S-INV');
        NoSeriesLine.FindLAST();
        dhbInvNo := NoSeriesLine."Last No. Used";
        SalesHeader.Init();
        SalesLine.Init();
    end;

    trigger OnPostXmlPort()
    begin
        NoSeriesLine."Last No. Used" := dhbInvNo;
        NoSeriesLine.Modify;
    end;

    var
        dhbWindow: Dialog;
        dhbLen: Integer;
        dhbPos: Integer;
        dhbYear: Integer;
        dhbPostingDate: Date;
        dhbDay: Integer;
        dhbMonth: Integer;
        BeginYearDate: Date;
        Cnt: Integer;
        dhbDept: Code[20];
        PostingDate: Date;
        NoSeriesLine: Record "No. Series Line";
        dhbInvNo: Code[20];
        SalesHeader: Record "Sales Header";
        SalesLine: record "Sales Line";
        dhbQty: Decimal;
        dhbMonthTxt: Text;
        dhbDayTxt: Text;
        dhbYearTxt: Text;
        dhbCustNo: code[20];
        dhbXRecCustNo: Code[20];
        dhbLineNo: Integer;

}
