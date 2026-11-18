reportextension 50100 "FC Check Stub Check Stub" extends "Check (Stub/Check/Stub)"
{
    dataset
    {
        add(GenJnlLine)
        {
            column(dhbAcctNo; GenJnlLine."Account No.") { }
            column(dhbAcctNoCaption; 'Buy from Vendor No.') { }
        }
        add(PrintSettledLoop)
        {
            column(dhbSig_1; 'P') { }
            column(dhbSig_2; 'S') { }
        }
    }
    rendering
    {
        layout(FC_CheckStubCheckStub)
        {
            Type = RDLC;
            LayoutFile = 'FC_CheckStubCheckStub.rdl';
        }
    }
    var
        dhbSig_1: text[5];
        dhbSig_2: text[5];

}