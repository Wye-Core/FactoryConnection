tableextension 50103 DimensionValues extends "Dimension Value"
{
    fields
    {
        field(50100; Manager; text[30])
        {
            Caption = 'Manager';
        }
        field(50101; "Square Footage"; Integer)
        {
            Caption = 'Square Footage';
        }
        field(50102; "Opening Date"; Date)
        {
            Caption = 'Opening Date';
        }
        field(50103; Region; Code[10])
        {
            Caption = 'Region';
        }
        field(50104; State; code[2])
        {
            Caption = 'State';
        }
        field(50105; Ethnicity; option)
        {
            Caption = 'Ethnicity';
            OptionMembers = ALL,HALF,HISPAN,PREP,URBAN;
        }
        field(50106; "Closing Date"; date)
        {
            Caption = 'Closing Date';
        }
    }
}
