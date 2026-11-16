pageextension 50102 DimensionValues extends "Dimension Values"
{
    layout
    {
        addafter("Dimension Value Type")

        {
            field(Manager; Rec.Manager)
            {
                ApplicationArea = ALL;
                Caption = 'Manager';
                Editable = true;
            }
            field("Square Footage"; Rec."Square Footage")
            {
                ApplicationArea = All;
                Caption = 'Square Footage';
                Editable = true;
            }
            field("Opening Date"; Rec."Opening Date")
            {
                ApplicationArea = All;
                Caption = 'Opening Date';
                Editable = true;
            }
            field(Region; Rec.Region)
            {
                ApplicationArea = All;
                Caption = 'Region';
                Editable = true;
            }
            field(State; Rec.State)
            {
                ApplicationArea = All;
                Caption = 'State';
                Editable = true;

            }
            field(Ethnicity; Rec.Ethnicity)
            {
                ApplicationArea = All;
                Caption = 'Ethnicity';
                Editable = true;
            }
            field("Closing Date"; Rec."Closing Date")
            {
                ApplicationArea = All;
                Caption = 'Closing Date';
                Editable = true;
            }
        }

    }
}
