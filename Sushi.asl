/*

-Developer-
2RU10SHI6 Tw:@2RU10SHI6
suika_lunch Tw:@suika_lunch

-Debugger-
syun_uta_tanuki Tw:@syun_uta_tanuki

Please contact to 2RU10SHI6 if there's any problem

*/

state("Sushi-Win64-Shipping")
{
    int souls : "Sushi-Win64-Shipping.exe", 0x04DF7480, 0x180, 0x1E8;
    int garis : "Sushi-Win64-Shipping.exe", 0x04DF3B68, 0xD28, 0x248;
    int eaten_sushi : "Sushi-Win64-Shipping.exe", 0x04DF7480, 0x118, 0x2D4;
    int difficulty_id : "Sushi-Win64-Shipping.exe", 0x04DF7480, 0x180, 0x228;
    int world_id : "Sushi-Win64-Shipping.exe", 0x04DF7480, 0x180, 0x1B0;
    int bamboo_rings : "Sushi-Win64-Shipping.exe", 0x048E4694;
    int layers : "Sushi-Win64-Shipping.exe", 0x04DF3B80, 0xE0, 0x270;
    float velocity_x : "Sushi-Win64-Shipping.exe", 0x04DEAF30, 0x0, 0xA0, 0x130, 0x3E8, 0xD0;
    float velocity_y : "Sushi-Win64-Shipping.exe", 0x04DEAF30, 0x0, 0xA0, 0x130, 0x3E8, 0xD4;
    float velocity_z : "Sushi-Win64-Shipping.exe", 0x04DEAF30, 0x0, 0xA0, 0x130, 0x3E8, 0xD8;
}

startup
{
    settings.Add("Parent",true,"Split at a time other timing than Sushi Soul");
    settings.Add("GateIn",true,"Split when go through the gate of \"The Great Sushi Ordeal\"","Parent");
    settings.Add("Skill",false,"Split when buy the \"Jet, Forward\"","Parent");
    settings.Add("Chikuwa",true,"Split when ate all Chikuwas","Parent");

    settings.Add("ED",false,"Use Autosplitter in Credit Game(True) or other categories(False)");
    settings.Add("Every10",false,"Split every 10 pieces of Sushi","ED");
    settings.Add("LoadRemover",true,"Use LoadRemover");

    settings.Add("SpeedDisplay",false,"Display Speed Checker on Text (please restart a game window after checked)");
    settings.Add("SpeedUse",false,"Use Speed Checker (DO NOT USE WHILE RUNNING)","SpeedDisplay");

    vars.init_bamboo_rings = 0;
    vars.in_ending = false;
}

init
{
    vars.tcss = new List<System.Windows.Forms.UserControl>();
    foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components)
    {
        if (component.GetType().Name == "TextComponent")
        {
            vars.tc = component;
            vars.tcss.Add(vars.tc.Settings);
        }
    }
}

update
{
    //ちくわ開始時のbamboo_ringsを保存
    if (old.bamboo_rings == current.bamboo_rings + 6 && current.souls == 16) vars.init_bamboo_rings = current.bamboo_rings;

    // speed checker
    if (settings["SpeedDisplay"] == false) return;
    if (vars.tcss.Count > 0)
    {
        vars.tcss[0].Text1 = "Speed";
        if(settings["SpeedUse"]){
            vars.speed_xyz = Math.Sqrt(Math.Pow(current.velocity_x, 2) + Math.Pow(current.velocity_y, 2) + Math.Pow(current.velocity_z, 2));
            vars.tcss[0].Text2 = Math.Round(vars.speed_xyz).ToString();
        } else {
            vars.tcss[0].Text2 = "Not checked";
        }

        if (vars.tcss.Count > 1)
        {
            vars.tcss[1].Text1 = "Horizonal speed";
            if(settings["SpeedUse"]){
                vars.speed_xy = Math.Sqrt(Math.Pow(current.velocity_x, 2) + Math.Pow(current.velocity_y, 2));
                vars.tcss[1].Text2 = Math.Round(vars.speed_xy).ToString();
            } else {
                vars.tcss[1].Text2 = "Not checked";
            }

            if (vars.tcss.Count > 2)
            {
                vars.tcss[2].Text1 = "Vertical speed";
                if(settings["SpeedUse"]){
                    vars.tcss[2].Text2 = Math.Round(current.velocity_z).ToString();
                } else {
                    vars.tcss[2].Text2 = "Not checked";
                }
            }
        }
    }
}

start
{
    if (settings["ED"])
    {
        return old.layers == 2 && current.layers == 1 && current.world_id == 0 && (current.bamboo_rings == 4 || current.bamboo_rings == 13);
    } else {
        return current.souls == 0 && current.garis == 0 && old.layers == 1 && current.layers == 0 && (current.bamboo_rings == 0 || current.bamboo_rings == 4 || current.bamboo_rings == 13);
    }
}

onStart
{
    //誤作動の回避のためbamboo_ringsが取り得ない大きな値を代入
    vars.init_bamboo_rings = 261046;
    
    if (settings["ED"] && current.world_id == 0 && old.layers == 2 && current.layers == 1 && (current.bamboo_rings == 4 || current.bamboo_rings == 13)) vars.in_ending = true; else vars.in_ending = false;
}

split
{
    if (settings["GateIn"] && current.souls == 0 && current.garis == 36 && current.difficulty_id != 0 && current.world_id == 0 && current.bamboo_rings == 0 && old.layers == 1 && current.layers == 0 && old.velocity_y != 0) return true;
    if (settings["Skill"] && old.garis == current.garis + 600 && current.difficulty_id != 0) return true;
    if (settings["Chikuwa"] && current.souls == 16 && old.bamboo_rings == vars.init_bamboo_rings + 4 && current.bamboo_rings == vars.init_bamboo_rings + 5 && current.world_id == 12 && current.layers == 1) return true;

    if (vars.in_ending && settings["ED"])
    {
        if (settings["Every10"] && current.eaten_sushi != 0 && current.eaten_sushi % 10 == 0 && old.eaten_sushi % 10 != 0) return true;
        if (current.eaten_sushi == 55 && old.eaten_sushi != 55) return true;
    }

    return current.souls == old.souls + 1 && old.difficulty_id != 0;
}

reset
{
    if (vars.in_ending && settings["ED"])
    {
        return current.difficulty_id == 0;
    } else {
        return (current.souls == 0 && current.garis == 0 && old.bamboo_rings == 1 && current.bamboo_rings == 2 && current.layers == 0) ||
                (current.souls == 0 && current.garis == 0 && current.eaten_sushi == 0 && current.difficulty_id == 0 && current.world_id == 0 && current.bamboo_rings == 0 && current.layers == 0);
    }  
}

isLoading
{
    return current.difficulty_id == 0 && settings["LoadRemover"];
}