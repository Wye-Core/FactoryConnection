pageextension 50109 PurchPaySetupPageExt extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("IMAT Document No."; Rec."IMAT Document No.")
            {
                ApplicationArea = All;
            }
        }
    }
}