pageextension 50101 ImportSalesInvoices extends "Sales Invoice List"
{
    actions
    {
        addlast(Processing)
        {
            action(ImportSalesInvoices)
            {
                ApplicationArea = All;
                Caption = 'Import Sales Invoices';
                Image = Import;

                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    Xmlport.run(50101, True, True);
                    CurrPage.Update();
                end;
            }
        }
    }

}
