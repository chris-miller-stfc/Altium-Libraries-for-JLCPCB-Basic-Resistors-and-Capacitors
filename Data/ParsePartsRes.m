function ParsePartsRes(FilePath,ExportFileName,Footprint_R)

String = fileread(FilePath);

Match_Groups = regexp(String,"(.*)[\r\t\n\s](.*)[\r\t\n\s]Basic.*[\n\t\r\s]*([\S].*)[\n\t\r\s]*([\S].*)\n",'tokens','dotexceptnewline');

Comment = strings(size(Match_Groups,2),1);
Description = Comment;
Value_Numeric = Comment;
Value_Numericd = zeros(size(Match_Groups,2),1);
Value = Comment;
Tolerance = Comment;
Power = Comment;
Voltage = Comment;
PPM = Comment;
Manufacturer_1 = Comment;
Manufacturer_Part_Number_1 = Comment;
Supplier_1 = Comment;
Supplier_Part_Number_1 = Comment;
Library_Ref = Comment;
Footprint_Ref = Comment;
Footprint_Path = Comment;
Library_Path = Comment;

for(i=1:size(Match_Groups,2))
    Manufacturer_T = strtrim(Match_Groups{i}{4});
    ManufacturerPartNumber_T = strtrim(Match_Groups{i}{1});
    Supplier_T = 'JLCPCB';
    SupplierPartNumber_T = strtrim(Match_Groups{i}{2});
    Value_String = strtrim(Match_Groups{i}{3});

    TempRegex = regexp(Value_String,"([0-9.]*mW)",'match','dotexceptnewline');
    if(~isempty(TempRegex))
        Power_T = TempRegex{1};
    else
        Power_T = '';
    end

    TempRegex = regexp(Value_String,"([0-9.]*V)",'match','dotexceptnewline');
    if(~isempty(TempRegex))
        Voltage_T = TempRegex{1};
    else
        Voltage_T = '';
    end

    TempRegex = regexp(Value_String,"([0-9.]*ppm)",'match','dotexceptnewline');
    if(~isempty(TempRegex))
        PPM_T = TempRegex{1};
    else
        PPM_T = '';
    end

    TempRegex = regexp(Value_String,"([0-9.]*%)",'match','dotexceptnewline');
    if(~isempty(TempRegex))
        Tolerance_T = TempRegex{1};
    else
        Tolerance_T = '';
    end

    TempRegex = regexp(Value_String,"([0-9.kmM]*)Ω",'tokens','dotexceptnewline');
    if(~isempty(TempRegex))
        TempRegex = TempRegex{1};
        TempRegex = TempRegex{1};
        K = contains(TempRegex,'k');
        m = contains(TempRegex,'m');
        M = contains(TempRegex,'M');
        TempRegex = strrep(TempRegex,'k','');
        TempRegex = strrep(TempRegex,'m','');
        TempRegex = strrep(TempRegex,'M','');
        Value_T = str2double(TempRegex);
        if(K)
            Value_T=Value_T*1000;
        elseif(M)
            Value_T=Value_T*1000000;
        elseif(m)
            Value_T=Value_T/1000;
        end
    else
        Value_T = '';
    end


    if(Value_T>=1000000)
        Value_S = sprintf('%g',Value_T/1000000);
        if(contains(Value_S,'.'))
            Value_S = strrep(Value_S,'.','M');
        else
            Value_S = [Value_S,'M'];
        end
    elseif(Value_T>=1000)
        Value_S = sprintf('%g',Value_T/1000);
        if(contains(Value_S,'.'))
            Value_S = strrep(Value_S,'.','K');
        else
            Value_S = [Value_S,'K'];
        end
    elseif(Value_T>=1)
        Value_S = sprintf('%g',Value_T);
        if(contains(Value_S,'.'))
            Value_S = strrep(Value_S,'.','R');
        else
            Value_S = [Value_S,'R'];
        end
    elseif(Value_T>0.001)
        Value_S = sprintf('%g',Value_T*1000);
        Value_S = [Value_S,'m'];
    elseif(Value_T==0)
        Value_S = '0R';
    else
        disp('Unhandled Value');
        disp(Value_T);
        disp(Value_String);
    end

    Comment(i) = string(['RES ',Value_S]);
    Description(i) = Value_String;
    Value_Numeric(i) = num2str(Value_T);
    Value_Numericd(i) = Value_T;
    Value(i) = string(Value_S);
    Tolerance(i) = string(Tolerance_T);
    Power(i) = string(Power_T);
    Voltage(i) = string(Voltage_T);
    PPM(i) = string(PPM_T);
    Manufacturer_1(i) = string(Manufacturer_T);
    Manufacturer_Part_Number_1(i) = string(ManufacturerPartNumber_T);
    Supplier_1(i) = string(Supplier_T);
    Supplier_Part_Number_1(i) = string(SupplierPartNumber_T);
    Library_Ref(i) = "Resistor";
    Footprint_Ref(i) = Footprint_R;
    Footprint_Path(i) = "Passives.PcbLib";
    Library_Path(i) = "Passives.SchLib";
end

[Value_Numericd,I] = sort(Value_Numericd);
Comment = Comment(I);
Description = Description(I);
Value = Value(I);
Value_Numeric = Value_Numeric(I);
Tolerance = Tolerance(I);
Power = Power(I);
Voltage = Voltage(I);
PPM = PPM(I);
Manufacturer_1 =Manufacturer_1(I);
Manufacturer_Part_Number_1 = Manufacturer_Part_Number_1(I);
Supplier_1 = Supplier_1(I);
Supplier_Part_Number_1 = Supplier_Part_Number_1(I);
Library_Ref = Library_Ref(I);
Footprint_Ref = Footprint_Ref(I);
Footprint_Path = Footprint_Path(I);
Library_Path = Library_Path(I);

DataBase = table(Comment,Description,Value_Numeric,Value,Tolerance,Power,Voltage,PPM,Manufacturer_1,Manufacturer_Part_Number_1,Supplier_1,Supplier_Part_Number_1,Library_Ref,Footprint_Ref,Footprint_Path,Library_Path);
for(i=1:length(DataBase.Properties.VariableNames))
    DataBase.Properties.VariableNames{i} = strrep(DataBase.Properties.VariableNames{i},'_',' ');
end

writetable(DataBase,ExportFileName);
end