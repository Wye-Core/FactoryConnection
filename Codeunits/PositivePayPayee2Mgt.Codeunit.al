codeunit 50112 PositivePayPayee2Mgt
{
    [EventSubscriber(ObjectType::Table, Database::"Positive Pay Detail", 'OnAfterInsertEvent', '', false, false)]
    local procedure PopulatePayee2(var Rec: Record "Positive Pay Detail"; RunTrigger: Boolean)
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
        Vendor: Record Vendor;
    begin
        if Rec.Payee2 <> '' then
            exit;

        CheckLedgerEntry.SetRange("Bank Account No.", Rec."Account Number");
        CheckLedgerEntry.SetRange("Check No.", Rec."Check Number");
        CheckLedgerEntry.SetRange("Check Date", Rec."Issue Date");
        CheckLedgerEntry.SetRange("Bal. Account Type", CheckLedgerEntry."Bal. Account Type"::Vendor);
        if not CheckLedgerEntry.FindFirst() then
            exit;

        if Vendor.Get(CheckLedgerEntry."Bal. Account No.") then begin
            Rec.Payee2 := CopyStr(Vendor."Name 2", 1, MaxStrLen(Rec.Payee2));
            Rec.Modify(false);
        end;
    end;
}