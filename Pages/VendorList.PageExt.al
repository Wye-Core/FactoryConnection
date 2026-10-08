pageextension 50108 VendorListExt extends "Vendor List"
{
    layout
    {
        addlast(Control1)
        {
            field("WDC Vendor Number"; Rec."WDC Vendor Number")
            {
                ApplicationArea = All;
            }
        }
    }
}