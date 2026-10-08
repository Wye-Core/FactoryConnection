tableextension 50102 PurchPaySetupExt extends "Purchases & Payables Setup"
{
    fields
    {
        field(50100; "IMAT Document No."; Code[20])
        {
            Caption = 'IMAT Document No.';
            DataClassification = CustomerContent;
        }
    }
}