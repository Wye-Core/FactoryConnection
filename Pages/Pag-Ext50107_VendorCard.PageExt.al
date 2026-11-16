pageextension 50107 VendorCardExt extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("WDC Vendor Number"; Rec."WDC Vendor Number")
            {
                ApplicationArea = All;
            }
        }
    }
}