
%% calculate saturation mass fraction for CO2

function yCO2_sat = calcSat(data,sat)
    
    %% GET ISOTHERM PARAMETERS
    i=data.currentSorbent;
    CO2IsothermModel = data.sorbent(i).CO2Isotherm.model;
   
    switch data.sorbent(i).CO2Isotherm.model
        case 'toth_cp'
            % CO2 isotherm
            T0 = data.sorbent(i).CO2Isotherm.T0(1);
            Xi_c = data.sorbent(i).CO2Isotherm.param(1);
            dH_c = data.sorbent(i).CO2Isotherm.param(2); % [J/mol]
            alpha_c = data.sorbent(i).CO2Isotherm.param(3);
            Xi_p = data.sorbent(i).CO2Isotherm.param(4);
            dH_p = data.sorbent(i).CO2Isotherm.param(5); % [J/mol]
            alpha_p = data.sorbent(i).CO2Isotherm.param(6);
            ns0_c = data.sorbent(i).CO2Isotherm.param(7); % [mol/kg]
            b0_c = data.sorbent(i).CO2Isotherm.param(8); % [1/MPa]
            t0_c = data.sorbent(i).CO2Isotherm.param(9);
            ns0_p = data.sorbent(i).CO2Isotherm.param(10); % [mol/kg]
            b0_p = data.sorbent(i).CO2Isotherm.param(11); % [1/MPa]
            t0_p = data.sorbent(i).CO2Isotherm.param(12);
        case 's_shaped'
            T0 = data.sorbent(i).CO2Isotherm.T0; % K
            q_L0 = data.sorbent(i).CO2Isotherm.param(1); % q_L0, mol/kg, a1
            b_L0 = data.sorbent(i).CO2Isotherm.param(2); % b_L0, 1/MPa, b0 
            dU_L = data.sorbent(i).CO2Isotherm.param(3); % dU_L, J/mol, b1 
            q_U0 = data.sorbent(i).CO2Isotherm.param(4); % q_U0, J/mol, c1 
            b_U0 = data.sorbent(i).CO2Isotherm.param(5); % b_U0, 1/MPa d0
            dU_U = data.sorbent(i).CO2Isotherm.param(6); % dU_U, J/mol d1
            b_H0 = data.sorbent(i).CO2Isotherm.param(7); % b_H0, mol/kg/Pa  bb0
            dU_H = data.sorbent(i).CO2Isotherm.param(8); % dU_H, J/mol bb1
            xi_1 = data.sorbent(i).CO2Isotherm.param(9); % xi1
            xi_2 = data.sorbent(i).CO2Isotherm.param(10); % xi_2, 1/K xi2
            p_step0 = data.sorbent(i).CO2Isotherm.param(11); % p_step0, MPa ps0
            dH_step = data.sorbent(i).CO2Isotherm.param(12); % dH_step, J/mol Hst
            gam = data.sorbent(i).CO2Isotherm.param(13); % gam            
        case 'DSL'
            n1 = data.sorbent(i).CO2Isotherm.param(1); % n1 (mol/kg)
            b0 = data.sorbent(i).CO2Isotherm.param(2); % b0 (m3/mol)
            Hb = data.sorbent(i).CO2Isotherm.param(3); % Hb (J/mol) 
            n2 = data.sorbent(i).CO2Isotherm.param(4); % n2 (mol/kg) 
            d0 = data.sorbent(i).CO2Isotherm.param(5); % d0 (m3/mol)
            Hd = data.sorbent(i).CO2Isotherm.param(6); % Hd (J/mol)
        case 'DSL2'
            T0 = data.sorbent(i).CO2Isotherm.T0; % K
            n1 = data.sorbent(i).CO2Isotherm.param(1); % n1 (mol/kg)
            b0 = data.sorbent(i).CO2Isotherm.param(2); % b0 (m3/mol)
            Hb = data.sorbent(i).CO2Isotherm.param(3); % Hb (J/mol) 
            n2 = data.sorbent(i).CO2Isotherm.param(4); % n2 (mol/kg) 
            d0 = data.sorbent(i).CO2Isotherm.param(5); % d0 (m3/mol)
            Hd = data.sorbent(i).CO2Isotherm.param(6); % Hd (J/mol)
        case 'toth'
            % CO2 isotherm
            T0 = data.sorbent(i).CO2Isotherm.T0(1);
            Xi = data.sorbent(i).CO2Isotherm.param(1);
            dH = data.sorbent(i).CO2Isotherm.param(2); % [J/mol]
            alpha = data.sorbent(i).CO2Isotherm.param(3);
            ns0 = data.sorbent(i).CO2Isotherm.param(4); % [mol/kg]
            b0 = data.sorbent(i).CO2Isotherm.param(5); % [1/MPa]
            t0 = data.sorbent(i).CO2Isotherm.param(6);
        case 'langm_freund'
            % CO2 isotherm
            T0 = data.sorbent(i).CO2Isotherm.T0(1);
            ns0 = data.sorbent(i).CO2Isotherm.param(1);
            Xi = data.sorbent(i).CO2Isotherm.param(2);
            t0 = data.sorbent(i).CO2Isotherm.param(3);
            alpha = data.sorbent(i).CO2Isotherm.param(4); % [mol/kg]
            b0 = data.sorbent(i).CO2Isotherm.param(5); % [1/MPa]
            dH = data.sorbent(i).CO2Isotherm.param(6); % [J/mol] 
    end   
    
    %% solver options
    options = optimoptions('lsqnonlin','Display','off');
    options.Algorithm = 'trust-region-reflective'; % levenberg-marquardt, trust-region-reflective
    options.OptimalityTolerance = 1e-16;
    options.FunctionTolerance = 1e-16;
    options.StepTolerance = 1e-16;
    options.MaxFunctionEvaluations = 6000;  	
    
    %% calculate composition at given saturation
    yCO2_sat = calcSat(data.feed.yCO2,sat,data.general.gasconstant,data.process.Tamb,data.process.pamb);

    %% function
    function yCO2_sat = calcSat(yCO2_feed,sat,R,Tamb,pamb)
            switch CO2IsothermModel
                case 'toth_cp'
                    qCO2_BT = ((ns0_c*exp(Xi_c*(1-Tamb/T0)).*(b0_c*exp(dH_c/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_feed))./((1+((b0_c*exp(dH_c/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_feed)).^(t0_c+alpha_c*(1-T0./Tamb))).^(1./(t0_c+alpha_c*(1-T0./Tamb)))))+((ns0_p*exp(Xi_p*(1-Tamb/T0)).*(b0_p*exp(dH_p/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_feed))./((1+((b0_p*exp(dH_p/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_feed)).^(t0_p+alpha_p*(1-T0./Tamb))).^(1./(t0_p+alpha_p*(1-T0./Tamb))))); % adsorbed amount of CO2
                case 's_shaped'            
                    qCO2_BT = (q_L0.*(b_L0.*exp(dU_L./(R*Tamb))).*(yCO2_feed*pamb)./(1+(b_L0.*exp(dU_L./(R*Tamb))).*(yCO2_feed*pamb))).*(1-((exp((log((yCO2_feed*pamb))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb))))./(1+exp(((log((yCO2_feed*pamb)))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb)))))).^gam))+(q_U0.*(b_U0.*exp(dU_U./(R*Tamb))).*(yCO2_feed*pamb)./(1+(b_U0.*exp(dU_U./(R*Tamb))).*(yCO2_feed*pamb))+(b_H0.*exp(dU_H./(R*Tamb))).*(yCO2_feed*pamb)).*((exp((log((yCO2_feed*pamb))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb))))./(1+exp(((log((yCO2_feed*pamb)))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb)))))).^gam); 
                case 'DSL'
                    qCO2_BT = n1*b0*exp(Hb/R/Tamb)*(yCO2_feed*pamb)./(1e-6*R*Tamb)./(1+b0*exp(Hb/R/Tamb).*(yCO2_feed*pamb)./(1e-6*R*Tamb)) + n2*d0*exp(Hd/R/Tamb)*(yCO2_feed*pamb)./(1e-6*R*Tamb)./(1+d0*exp(Hd/R/Tamb).*(yCO2_feed*pamb)./(1e-6*R*Tamb));            
                case 'DSL2'
                    qCO2_BT = n1*b0*exp(Hb/R/Tamb)*(yCO2_feed*pamb)./(1+b0*exp(Hb/R/Tamb).*(yCO2_feed*pamb)) + n2*d0*exp(Hd/R/Tamb)*(yCO2_feed*pamb)./(1+d0*exp(Hd/R/Tamb).*(yCO2_feed*pamb));            
                case 'toth'
                    qCO2_BT = ((ns0*exp(Xi*(1-Tamb/T0)).*(b0*exp(dH/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_feed))./((1+((b0*exp(dH/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_feed)).^(t0+alpha*(1-T0./Tamb))).^(1./(t0+alpha*(1-T0./Tamb)))));                       
                case 'langm_freund'
                    qCO2_BT = (ns0.*exp(Xi.*(1-Tamb./T0))).*((b0*exp(dH./(R*T0).*(T0./Tamb-1))).*(pamb*yCO2_feed)).^(1./t0+alpha.*(1-T0./Tamb))./(1+ ((b0*exp(dH./(R*T0).*(T0./Tamb-1))).*(pamb*yCO2_feed)).^(1./t0+alpha.*(1-T0./Tamb)));
            end  
        qCO2 = qCO2_BT-(1-sat)*qCO2_BT;

            switch CO2IsothermModel
                case 'toth_cp'
                    fun2 = @(yCO2_sat) qCO2 - (((ns0_c*exp(Xi_c*(1-Tamb/T0)).*(b0_c*exp(dH_c/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_sat))./((1+((b0_c*exp(dH_c/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_sat)).^(t0_c+alpha_c*(1-T0./Tamb))).^(1./(t0_c+alpha_c*(1-T0./Tamb)))))+((ns0_p*exp(Xi_p*(1-Tamb/T0)).*(b0_p*exp(dH_p/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_sat))./((1+((b0_p*exp(dH_p/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_sat)).^(t0_p+alpha_p*(1-T0./Tamb))).^(1./(t0_p+alpha_p*(1-T0./Tamb)))))); % adsorbed amount of CO2
                case 's_shaped'            
                    fun2 = @(yCO2_sat) qCO2 - ((q_L0.*(b_L0.*exp(dU_L./(R*Tamb))).*(yCO2_sat*pamb)./(1+(b_L0.*exp(dU_L./(R*Tamb))).*(yCO2_sat*pamb))).*(1-((exp((log((yCO2_sat*pamb))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb))))./(1+exp(((log((yCO2_sat*pamb)))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb)))))).^gam))+(q_U0.*(b_U0.*exp(dU_U./(R*Tamb))).*(yCO2_sat*pamb)./(1+(b_U0.*exp(dU_U./(R*Tamb))).*(yCO2_sat*pamb))+(b_H0.*exp(dU_H./(R*Tamb))).*(yCO2_sat*pamb)).*((exp((log((yCO2_sat*pamb))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb))))./(1+exp(((log((yCO2_sat*pamb)))-log(p_step0.*exp(-dH_step./R.*(1/T0-1/Tamb))))./(xi_1.*exp(xi_2.*(1./T0-1./Tamb)))))).^gam)); 
                case 'DSL'
                    fun2 = @(yCO2_sat) qCO2 - (n1*b0*exp(Hb/R/Tamb)*(yCO2_sat*pamb)./(1e-6*R*Tamb)./(1+b0*exp(Hb/R/Tamb).*(yCO2_sat*pamb)./(1e-6*R*Tamb)) + n2*d0*exp(Hd/R/Tamb)*(yCO2_sat*pamb)./(1e-6*R*Tamb)./(1+d0*exp(Hd/R/Tamb).*(yCO2_sat*pamb)./(1e-6*R*Tamb)));            
                case 'DSL2'
                    fun2 = @(yCO2_sat) qCO2 - (n1*b0*exp(Hb/R/Tamb)*(yCO2_sat*pamb)./(1+b0*exp(Hb/R/Tamb).*(yCO2_sat*pamb)) + n2*d0*exp(Hd/R/Tamb)*(yCO2_sat*pamb)./(1+d0*exp(Hd/R/Tamb).*(yCO2_sat*pamb)));            
                 case 'toth'
                    fun2 = @(yCO2_sat) qCO2 - (((ns0*exp(Xi*(1-Tamb/T0)).*(b0*exp(dH/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_sat))./((1+((b0*exp(dH/(R*T0)*(T0./Tamb-1))).*(pamb*yCO2_sat)).^(t0+alpha*(1-T0./Tamb))).^(1./(t0+alpha*(1-T0./Tamb))))));           
                case 'langm_freund'
                    fun2 = @(yCO2_sat) qCO2 - ((ns0.*exp(Xi.*(1-Tamb./T0))).*((b0*exp(dH./(R*T0).*(T0./Tamb-1))).*(pamb*yCO2_sat)).^(1./t0+alpha.*(1-T0./Tamb))./(1+ ((b0*exp(dH./(R*T0).*(T0./Tamb-1))).*(pamb*yCO2_sat)).^(1./t0+alpha.*(1-T0./Tamb))));
            end     

        x02 = yCO2_feed;
        lb2 = 0;
        ub2 = 1;
        yCO2_sat = lsqnonlin(fun2,x02,lb2,ub2);
    end
end
    
    
    
    