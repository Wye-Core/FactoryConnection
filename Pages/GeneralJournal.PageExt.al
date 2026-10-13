pageextension 50110 GenJnlExt extends "General Journal"
{
    actions
    {
        addlast(Processing)
        {
            action(EpicorSAImport)
            {
                Caption = 'Epicor SA Import';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                begin
                    EpicorSAImport.GetJnlInfo(Rec."Journal Template Name", Rec."Journal Batch Name");
                    EpicorSAImport.Run();
                    CurrPage.Update();
                end;
            }

            action(EpicorSLImport)
            {
                Caption = 'Epicor SL Import';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                begin
                    EpicorSLImport.GetJnlInfo(Rec."Journal Template Name", Rec."Journal Batch Name");
                    EpicorSLImport.Run();
                    CurrPage.Update();
                end;
            }

            action(GLImport)
            {
                Caption = 'GL Import';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                begin
                    GLImport.GetJnlInfo(Rec."Journal Template Name", Rec."Journal Batch Name");
                    GLImport.Run();
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        EpicorSAImport: XmlPort Epicor_SAImport;
        EpicorSLImport: XmlPort Epicor_SLImport;
        GLImport: XmlPort GL_Import;
}