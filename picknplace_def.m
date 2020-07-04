classdef picknplace_def < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Estado1                         matlab.ui.control.TextArea
        Estado2                         matlab.ui.control.TextArea
        camara                          matlab.ui.control.UIAxes
        EspaciooperacionalLabel         matlab.ui.control.Label
        EspacioconfiguracionesLabel     matlab.ui.control.Label
        PICKPLACELabel                  matlab.ui.control.Label
        EstadoLabel                     matlab.ui.control.Label
        stopButton                      matlab.ui.control.StateButton
        startButton                     matlab.ui.control.StateButton
        AUTOMTICOButton                 matlab.ui.control.StateButton
        MANUALButton                    matlab.ui.control.StateButton
        unoButton                       matlab.ui.control.StateButton
        dosButton                       matlab.ui.control.StateButton
        tresButton                      matlab.ui.control.StateButton
        gripperButton                   matlab.ui.control.StateButton
        gripperState                    matlab.ui.control.TextArea
        GripperLabel                    matlab.ui.control.Label
        resetButton                     matlab.ui.control.Button
        joint1State                     matlab.ui.control.TextArea
        joint2State                     matlab.ui.control.TextArea
        joint3State                     matlab.ui.control.TextArea
        joint4State                     matlab.ui.control.TextArea
        Joint1Label                     matlab.ui.control.Label
        Joint2Label                     matlab.ui.control.Label
        Joint3Label                     matlab.ui.control.Label
        Joint4Label                     matlab.ui.control.Label
        xState                          matlab.ui.control.TextArea
        yState                          matlab.ui.control.TextArea
        zState                          matlab.ui.control.TextArea
        XLabel                          matlab.ui.control.Label
        YLabel                          matlab.ui.control.Label
        ZLabel                          matlab.ui.control.Label
        closeButton                     matlab.ui.control.Button
        TutorialButton                  matlab.ui.control.StateButton
        ConexinButton                   matlab.ui.control.StateButton
        autoState                       matlab.ui.control.TextArea
        CargandoLabel                   matlab.ui.control.Label
        unoLabel                        matlab.ui.control.Label
        dosLabel                        matlab.ui.control.Label
        tresLabel                       matlab.ui.control.Label
        ConexionPanel                   matlab.ui.container.Panel
        CONEXINROSLabel                 matlab.ui.control.Label
        DirectaCheckBox                 matlab.ui.control.CheckBox
        SeleccioneunaopcinLabel         matlab.ui.control.Label
        MquinaVirtualVMCheckBox         matlab.ui.control.CheckBox
        CONECTARButton                  matlab.ui.control.StateButton
        DESCONECTARButton               matlab.ui.control.Button
        DireccinIPLocalEditFieldLabel   matlab.ui.control.Label
        DireccinIPLocalEditField        matlab.ui.control.EditField
        EstadoROSLabel                  matlab.ui.control.Label
        DireccinIPRemotaEditFieldLabel  matlab.ui.control.Label
        DireccinIPRemotaEditField       matlab.ui.control.EditField
    end

    
    properties (Access = private)
        home_2_entrada_up; 
        entrada_up_2_home;
        entrada_up_2_entrada_down;
        entrada_down_2_entrada_up;
        entrada_up_2_salida1_up;
        salida1_up_2_salida1_down;
        salida1_down_2_salida1_up;
        salida1_up_2_home;
        entrada_up_2_salida2_up;
        salida2_up_2_salida2_down;
        salida2_down_2_salida2_up;
        salida2_up_2_home;
        entrada_up_2_salida3_up;
        salida3_up_2_salida3_down;
        salida3_down_2_salida3_up;
        salida3_up_2_home;
        salida1_up_2_salida2_up;
        salida2_up_2_salida1_up;
        salida1_up_2_salida3_up;
        salida3_up_2_salida1_up;
        opened;
        closed;
        Phantom SerialLink;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            %Configuración Cámara    
        
            title(app.camara, []);
            xlabel(app.camara, []);
            ylabel(app.camara, []);
            app.camara.XAxis.TickLabels = {};
            app.camara.YAxis.TickLabels = {};    
        
            %% Construccion Phantom
            
            L0 = 0.137; L1 = 0.105; L2 = 0.105; L3 = 0.110; 
            q1 = 0; q2 = 0; q3 = 0; q4 = 0;

            %         dh(thetai,      di,      ai-1,  alpha-1,   sigma, offset)
            dh1(1,:)= [ q1,        L0,       0,         0,         0,      0];
            dh1(2,:)= [ q2,        0,        0,        pi/2,       0,      pi/2];
            dh1(3,:)= [ q3,        0,        L1,        0,         0,      0];
            dh1(4,:)= [ q4,        0,        L2,        0,         0,      0];

            % Eslabones++
            L(1) = Link(dh1(1,:), 'modified','qlim',[-1.5*pi 1.5*pi]);
            L(2) = Link(dh1(2,:), 'modified','qlim',[-2/3*pi 2/3*pi]);
            L(3) = Link(dh1(3,:), 'modified','qlim',[-1.5*pi 1.5*pi]);
            L(4) = Link(dh1(4,:), 'modified','qlim',[-1.5*pi 1.5*pi]);

            %Representación
            app.Phantom = SerialLink(L,'name','Phantom');
            app.Phantom.tool = transl([L3 0 0])*round(trotz(pi/2))*round(trotx(pi/2));

            %% Puntos pick and place

            entrada = [0 -0.25];
            pose_entrada = [90 0 90]; % 90 90 por ubicarse en el cuarto cuadrante 

            salida1 = [0.175 0.25];
            pose_salida1 = [-90 atan2(salida1(2),salida1(1))*180/pi -90]; % 90 90 por ubicarse en el primer cuadrante X-Y 

            salida2 = [0.09 0.25];
            pose_salida2 = [-90 atan2(salida2(2),salida2(1))*180/pi -90]; % 90 90 por ubicarse en el primer cuadrante X-Y 

            salida3 = [0.02 0.25];
            pose_salida3 = [-90 atan2(salida3(2),salida3(1))*180/pi -90]; % 90 90 por ubicarse en el primer cuadrante X-Y 

            up = 0.137;
            down = 0.03; %Altura mínima
            
            % Griper
            app.opened = 0.02;
            app.closed = 0.005;
            
            %% Coordenadas pick and place

            home = [0.25 0 0.137 -90 89.9 -90];

            entrada_up = [entrada up pose_entrada];
            salida1_up = [salida1 up pose_salida1];
            salida2_up = [salida2 up pose_salida2];
            salida3_up = [salida3 up pose_salida3];

            entrada_down = [entrada down pose_entrada];
            salida1_down = [salida1 down pose_salida1];
            salida2_down = [salida2 down pose_salida2];
            salida3_down = [salida3 down pose_salida3];

            %% Matrices de transformacion homogenea
            
            T_home = transl(home(1:3))*rpy2tr(home(4:6),'deg');
            T_entrada_up = transl(entrada_up(1:3))*rpy2tr(entrada_up(4:6),'deg');
            T_salida1_up = transl(salida1_up(1:3))*rpy2tr(salida1_up(4:6),'deg');
            T_salida2_up = transl(salida2_up(1:3))*rpy2tr(salida2_up(4:6),'deg');
            T_salida3_up = transl(salida3_up(1:3))*rpy2tr(salida3_up(4:6),'deg');

            T_entrada_down = transl(entrada_down(1:3))*rpy2tr(entrada_down(4:6),'deg');
            T_salida1_down = transl(salida1_down(1:3))*rpy2tr(salida1_down(4:6),'deg');
            T_salida2_down = transl(salida2_down(1:3))*rpy2tr(salida2_down(4:6),'deg');
            T_salida3_down = transl(salida3_down(1:3))*rpy2tr(salida3_down(4:6),'deg');

            %%  Cinematica inversa
            
            ik_home = app.Phantom.ikunc(T_home);
            ik_entrada_up = app.Phantom.ikunc(T_entrada_up,ik_home);
            ik_salida1_up = app.Phantom.ikunc(T_salida1_up,ik_entrada_up);
            ik_salida2_up = app.Phantom.ikunc(T_salida2_up,ik_salida1_up);
            ik_salida3_up = app.Phantom.ikunc(T_salida3_up,ik_entrada_up);

            ik_entrada_down = app.Phantom.ikunc(T_entrada_down,ik_entrada_up);
            ik_salida1_down = app.Phantom.ikunc(T_salida1_down,ik_salida1_up);
            ik_salida2_down = app.Phantom.ikunc(T_salida2_down,ik_salida2_up);
            ik_salida3_down = app.Phantom.ikunc(T_salida3_down,ik_salida3_up);
            
            %% Trayectorias

            t = (0:0.01:0.2);  
            app.home_2_entrada_up = jtraj(ik_home,ik_entrada_up,t);
            app.entrada_up_2_home = jtraj(ik_entrada_up,ik_home,t);

            app.entrada_up_2_entrada_down = jtraj(ik_entrada_up,ik_entrada_down,t);
            app.entrada_down_2_entrada_up = jtraj(ik_entrada_down,ik_entrada_up,t);

            app.entrada_up_2_salida1_up = jtraj(ik_entrada_up,ik_salida1_up,t);
            app.salida1_up_2_salida1_down = jtraj(ik_salida1_up,ik_salida1_down,t);
            app.salida1_down_2_salida1_up = jtraj(ik_salida1_down,ik_salida1_up,t);
            app.salida1_up_2_home = jtraj(ik_salida1_up,ik_home,t);

            app.entrada_up_2_salida2_up = jtraj(ik_entrada_up,ik_salida2_up,t);
            app.salida2_up_2_salida2_down = jtraj(ik_salida2_up,ik_salida2_down,t);
            app.salida2_down_2_salida2_up = jtraj(ik_salida2_down,ik_salida2_up,t);
            app.salida2_up_2_home = jtraj(ik_salida2_up,ik_home,t);

            app.entrada_up_2_salida3_up = jtraj(ik_entrada_up,ik_salida3_up,t);
            app.salida3_up_2_salida3_down = jtraj(ik_salida3_up,ik_salida3_down,t);
            app.salida3_down_2_salida3_up = jtraj(ik_salida3_down,ik_salida3_up,t);
            app.salida3_up_2_home = jtraj(ik_salida3_up,ik_home,t);

            app.salida1_up_2_salida2_up = jtraj(ik_salida1_up,ik_salida2_up,t);
            app.salida2_up_2_salida1_up = jtraj(ik_salida2_up,ik_salida1_up,t);
            app.salida1_up_2_salida3_up = jtraj(ik_salida1_up,ik_salida3_up,t);
            app.salida3_up_2_salida1_up = jtraj(ik_salida3_up,ik_salida1_up,t);
            
            pause(20);
            app.CargandoLabel.Text = ("Seleccione una conexión");
        end

        % Value changed function: AUTOMTICOButton
        function AUTOMTICOButtonValueChanged(app, event)
            value = app.AUTOMTICOButton.Value;
            if(value == 1)
                app.Estado2.Value = 'AUTOMÁTICO';
                app.startButton.Enable = 'off';
                app.MANUALButton.Value = 0;
                app.autoState.Visible = 'on';
                app.unoButton.Enable = 'on';
                app.dosButton.Enable = 'on';
                app.tresButton.Enable = 'on';
                app.unoLabel.FontColor = [0.00,0.00,0.00];
                app.dosLabel.FontColor = [0.00,0.00,0.00];
                app.tresLabel.FontColor = [0.00,0.00,0.00];
                app.gripperButton.Enable = 'off';
                app.GripperLabel.FontColor = [0.15,0.15,0.15];
                app.gripperState.FontColor = [0.65,0.65,0.65];
                app.gripperState.Value = 'ABIERTO';
                app.gripperButton.Value = false;
            end
            if(value == 0)
                app.Estado2.Value = '';
                app.autoState.Visible = 'off';
                app.startButton.Enable = 'off';
                app.unoButton.Enable = 'off';
                app.dosButton.Enable = 'off';
                app.tresButton.Enable = 'off';
                app.unoLabel.FontColor = [0.15,0.15,0.15];
                app.dosLabel.FontColor = [0.15,0.15,0.15];
                app.tresLabel.FontColor = [0.15,0.15,0.15];
                app.unoButton.Value = false;
                app.dosButton.Value = false;
                app.tresButton.Value = false;
                app.autoState.Value = '';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Value changed function: MANUALButton
        function MANUALButtonValueChanged(app, event)
            value = app.MANUALButton.Value;
            if(value == 1)
                app.Estado2.Value = 'MANUAL';
                app.AUTOMTICOButton.Value = 0;
                app.autoState.Visible = 'off';
                app.autoState.Value = '';
                app.unoButton.Value = 0;
                app.dosButton.Value = 0;
                app.tresButton.Value = 0;
                if(app.CONECTARButton.Value == 1)
                    app.startButton.Enable = 'on';
                end
                app.unoButton.Enable = 'off';
                app.dosButton.Enable = 'off';
                app.tresButton.Enable = 'off';
                app.unoLabel.FontColor = [0.15,0.15,0.15];
                app.dosLabel.FontColor = [0.15,0.15,0.15];
                app.tresLabel.FontColor = [0.15,0.15,0.15];
                app.CargandoLabel.Text = 'Listo para usarse';
            end
            if(value == 0)
                app.Estado2.Value = '';
                app.startButton.Enable = 'off';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Value changed function: stopButton
        function stopButtonValueChanged(app, event)
            value = app.stopButton.Value;
            if(value == 1)
                app.Estado1.Value = 'PARADA';
                app.startButton.Value = 0;
                app.unoButton.Value = 0;
                app.dosButton.Value = 0;
                app.tresButton.Value = 0;
                app.AUTOMTICOButton.Value = 0;
                app.unoButton.Enable = 'off';
                app.dosButton.Enable = 'off';
                app.tresButton.Enable = 'off';
                app.unoLabel.FontColor = [0.15,0.15,0.15];
                app.dosLabel.FontColor = [0.15,0.15,0.15];
                app.tresLabel.FontColor = [0.15,0.15,0.15];
                app.autoState.Visible = 'off';
                app.autoState.Value = '';
                app.MANUALButton.Value = 0;
                app.gripperButton.Enable = 'off';
                app.GripperLabel.FontColor = [0.15,0.15,0.15];
                app.gripperState.FontColor = [0.65,0.65,0.65];
                app.gripperState.Value = 'ABIERTO';
                app.gripperButton.Value = false;
                app.Estado2.Value = '';
                app.startButton.Enable = 'off';
                if(app.CONECTARButton.Value == 1)
                    app.AUTOMTICOButton.Enable = 'on';
                    app.MANUALButton.Enable = 'on';
                    app.resetButton.Enable = 'on';
                    app.CargandoLabel.Text = 'Seleccione modo de operación';
                end
            end
        end

        % Value changed function: startButton
        function startButtonValueChanged(app, event)
            value = app.startButton.Value;
            if(value == 1)
                app.CargandoLabel.Text = 'Inicializando . . .';
                cam = rossubscriber('/Phantom_sim/mybot/camera/image_raw/compressed');
                img = readImage(receive(cam));
                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                    'YData', [1 app.camara.Position(4)]);
                app.camara.XLim = [0 I.XData(2)];
                app.camara.YLim = [0 I.YData(2)];
                %est = rossubscriber('/Phantom_sim/joint_states','sensor_msgs/JointState');
                publicadores(1) = rospublisher('/Phantom_sim/joint1_position_controller/command','std_msgs/Float64');
                publicadores(2) = rospublisher('/Phantom_sim/joint2_position_controller/command','std_msgs/Float64');
                publicadores(3) = rospublisher('/Phantom_sim/joint3_position_controller/command','std_msgs/Float64');
                publicadores(4) = rospublisher('/Phantom_sim/joint4_position_controller/command','std_msgs/Float64');
                publicadores(5) = rospublisher('/Phantom_sim/joint5_position_controller/command','std_msgs/Float64');
                publicadores(6) = rospublisher('/Phantom_sim/joint6_position_controller/command','std_msgs/Float64');
                joydata = rossubscriber('/joy');
                x1 = 0.25;
                y1 = 0;
                z1 = 0.137;
                app.Estado1.Value = 'OPERACIÓN';
                app.stopButton.Value = 0;
                app.AUTOMTICOButton.Enable = 'off';
                app.MANUALButton.Enable = 'off';
                app.unoButton.Enable = 'off';
                app.dosButton.Enable = 'off';
                app.tresButton.Enable = 'off';
                app.unoLabel.FontColor = [0.15,0.15,0.15];
                app.dosLabel.FontColor = [0.15,0.15,0.15];
                app.tresLabel.FontColor = [0.15,0.15,0.15];
                app.startButton.Enable = 'off';
                pause(1);
                app.CargandoLabel.Text = '';
                while(app.stopButton.Value ~= 1)
                if(app.AUTOMTICOButton.Value == 1)
                    if(app.unoButton.Value == 1)
                        %% Trayectoria 1 en ROS
                        app.CargandoLabel.Text = 'Conexión exitosa';
                        msg= rosmessage('std_msgs/Float64');
                        %1
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.home_2_entrada_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %2
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.home_2_entrada_up(20,:) app.opened app.opened];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %3 
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_up_2_entrada_down(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %4
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.entrada_up_2_entrada_down(20,:) app.closed app.closed];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %5
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_down_2_entrada_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %6
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_up_2_salida1_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %7
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida1_up_2_salida1_down(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %8
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.salida1_up_2_salida1_down(20,:) app.opened app.opened];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %9
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida1_down_2_salida1_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %10
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.salida1_down_2_salida1_up(20,:) app.closed app.closed];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %11
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida1_up_2_home(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        
                        pause(1);
                        app.stopButton.Value = 1;
                        app.startButton.Value = 0;
                        app.Estado1.Value = 'PARADA';
                        app.unoButton.Value = 0;
                        app.dosButton.Value = 0;
                        app.tresButton.Value = 0;
                        app.AUTOMTICOButton.Value = 0;
                        app.MANUALButton.Value = 0;
                        app.Estado2.Value = '';
                        app.autoState.Visible = 'off';
                        app.autoState.Value = '';
                        app.startButton.Enable = 'off';
                        app.AUTOMTICOButton.Enable = 'on';
                        app.MANUALButton.Enable = 'on';
                        app.gripperButton.Enable = 'off';
                        app.GripperLabel.FontColor = [0.15,0.15,0.15];
                        app.gripperState.FontColor = [0.65,0.65,0.65];
                        app.gripperState.Value = 'ABIERTO';
                        app.gripperButton.Value = false;
                        app.joint1State.Value = '';
                        app.joint2State.Value = '';
                        app.joint3State.Value = '';
                        app.joint4State.Value = '';
                        app.xState.Value = '';
                        app.yState.Value = '';
                        app.zState.Value = '';
                        app.CargandoLabel.Text = 'Seleccione modo de operación';
                    end
                    
                    if(app.dosButton.Value == 1)
                        %% Trayectoria 2 en ROS
                        app.CargandoLabel.Text = 'Conexión exitosa';
                        msg= rosmessage('std_msgs/Float64');
                        %1
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.home_2_entrada_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %2
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.home_2_entrada_up(20,:) app.opened app.opened];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %3
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_up_2_entrada_down(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %4
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.entrada_up_2_entrada_down(20,:) app.closed app.closed];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %5
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_down_2_entrada_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %6
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_up_2_salida2_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %7
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida2_up_2_salida2_down(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %8
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.salida2_up_2_salida2_down(20,:) app.opened app.opened];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %9
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida2_down_2_salida2_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %10
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.salida2_down_2_salida2_up(20,:) app.closed app.closed];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %11
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida2_up_2_home(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        
                        pause(1);
                        app.stopButton.Value = 1;
                        app.startButton.Value = 0;
                        app.Estado1.Value = 'PARADA';
                        app.unoButton.Value = 0;
                        app.dosButton.Value = 0;
                        app.tresButton.Value = 0;
                        app.AUTOMTICOButton.Value = 0;
                        app.MANUALButton.Value = 0;
                        app.Estado2.Value = '';
                        app.autoState.Visible = 'off';
                        app.autoState.Value = '';
                        app.startButton.Enable = 'off';
                        app.AUTOMTICOButton.Enable = 'on';
                        app.MANUALButton.Enable = 'on';
                        app.gripperButton.Enable = 'off';
                        app.GripperLabel.FontColor = [0.15,0.15,0.15];
                        app.gripperState.FontColor = [0.65,0.65,0.65];
                        app.gripperState.Value = 'ABIERTO';
                        app.gripperButton.Value = false;
                        app.joint1State.Value = '';
                        app.joint2State.Value = '';
                        app.joint3State.Value = '';
                        app.joint4State.Value = '';
                        app.xState.Value = '';
                        app.yState.Value = '';
                        app.zState.Value = '';
                        app.CargandoLabel.Text = 'Seleccione modo de operación';
                    end
                    
                    if(app.tresButton.Value == 1)
                        %% Trayectoria 2 en ROS
                        app.CargandoLabel.Text = 'Conexión exitosa';
                        msg= rosmessage('std_msgs/Float64');
                        %1
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.home_2_entrada_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %2
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.home_2_entrada_up(20,:) app.opened app.opened];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %3
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_up_2_entrada_down(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %4
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.entrada_up_2_entrada_down(20,:) app.closed app.closed];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %5
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_down_2_entrada_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %6
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.entrada_up_2_salida3_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %7
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida3_up_2_salida3_down(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %8
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.salida3_up_2_salida3_down(20,:) app.opened app.opened];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %9
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida3_down_2_salida3_up(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,10) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        %10
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = [app.salida3_down_2_salida3_up(20,:) app.closed app.closed];
                            for i=1:6
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            pause(0.05)
                        end
                        img = readImage(receive(cam));
                        I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                               'YData', [1 app.camara.Position(4)]);
                        app.camara.XLim = [0 I.XData(2)];
                        app.camara.YLim = [0 I.YData(2)];
                        %11
                        for a=1:20
                            if(app.stopButton.Value == 1)
                                break;
                            end
                            angulos = app.salida3_up_2_home(a,:);
                            for i=1:4
                                msg.Data = angulos(i);
                                send(publicadores(i),msg)
                            end
                            %msg2 = receive(est,10);
                            %app.joint1State.Value = string(msg2.Position(1));
                            %app.joint2State.Value = string(msg2.Position(2));
                            %app.joint3State.Value = string(msg2.Position(3));
                            %app.joint4State.Value = string(msg2.Position(4));
                            angulosa = angulos(1:4);
                            app.joint1State.Value = string(angulosa(1));
                            app.joint2State.Value = string(angulosa(2));
                            app.joint3State.Value = string(angulosa(3));
                            app.joint4State.Value = string(angulosa(4));
                            fk = app.Phantom.fkine(angulosa);
                            app.xState.Value = string(fk(1,4));
                            app.yState.Value = string(fk(2,4));
                            app.zState.Value = string(fk(3,4));
                            if mod(a,5) ==0
                                img = readImage(receive(cam));
                                I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                                    'YData', [1 app.camara.Position(4)]);
                                app.camara.XLim = [0 I.XData(2)];
                                app.camara.YLim = [0 I.YData(2)];
                            end
                            pause(0.2)
                        end
                        
                        pause(1);
                        app.stopButton.Value = 1;
                        app.startButton.Value = 0;
                        app.Estado1.Value = 'PARADA';
                        app.unoButton.Value = 0;
                        app.dosButton.Value = 0;
                        app.tresButton.Value = 0;
                        app.AUTOMTICOButton.Value = 0;
                        app.MANUALButton.Value = 0;
                        app.Estado2.Value = '';
                        app.autoState.Visible = 'off';
                        app.autoState.Value = '';
                        app.startButton.Enable = 'off';
                        app.AUTOMTICOButton.Enable = 'on';
                        app.MANUALButton.Enable = 'on';
                        app.gripperButton.Enable = 'off';
                        app.GripperLabel.FontColor = [0.15,0.15,0.15];
                        app.gripperState.FontColor = [0.65,0.65,0.65];
                        app.gripperState.Value = 'ABIERTO';
                        app.gripperButton.Value = false;
                        app.joint1State.Value = '';
                        app.joint2State.Value = '';
                        app.joint3State.Value = '';
                        app.joint4State.Value = '';
                        app.xState.Value = '';
                        app.yState.Value = '';
                        app.zState.Value = '';
                        app.CargandoLabel.Text = 'Seleccione modo de operación';
                    end
                    
                elseif(app.MANUALButton.Value == 1)
                    app.CargandoLabel.Text = 'Conexión exitosa';
                    msg= rosmessage('std_msgs/Float64');
                    app.gripperButton.Enable = 'on';
                    app.GripperLabel.FontColor = [0,0,0];
                    app.gripperState.FontColor = [0,0,0];
                    img = readImage(receive(cam));
                    I = imshow(img, 'Parent', app.camara, 'XData', [1 app.camara.Position(3)], ...
                        'YData', [1 app.camara.Position(4)]);
                    app.camara.XLim = [0 I.XData(2)];
                    app.camara.YLim = [0 I.YData(2)];
                    
                    h=receive(joydata);
                    x_axis= double(h.Axes(1));
                    y_axis= double(h.Axes(2));    
                    z_axis= double(h.Axes(5));
                    
                    x = -0.32*x_axis;  
                    y = 0.32*y_axis;
                    
                    if z_axis>0
                        z = 0.457*z_axis;
                    else
                        z = 0;
                    end
                    
                    if y>0
                        ori = [90 atan2(y,x) -90];
                    else 
                        ori = [-90 atan2(y,x) 90];
                    end
                    tray1 = transl(x1,y1,z1)*rpy2tr(ori);
                    tray= transl(x,y,z)*rpy2tr(ori);
                    invtray = app.Phantom.ikunc(tray1);
                    invhome = app.Phantom.ikunc(tray,invtray);
                    for i=1:4 
                        msg.Data = invhome(i);
                        send(publicadores(i),msg)
                    end
                    x1 = x;
                    y1 = y;
                    z1 = z;
                    if(app.stopButton.Value == 1)
                        pause(1);
                        app.stopButton.Value = 1;
                        app.startButton.Value = 0;
                        app.Estado1.Value = 'PARADA';
                        app.unoButton.Value = 0;
                        app.dosButton.Value = 0;
                        app.tresButton.Value = 0;
                        app.AUTOMTICOButton.Value = 0;
                        app.MANUALButton.Value = 0;
                        app.Estado2.Value = '';
                        app.autoState.Visible = 'off';
                        app.autoState.Value = '';
                        app.startButton.Enable = 'off';
                        app.AUTOMTICOButton.Enable = 'on';
                        app.MANUALButton.Enable = 'on';
                        app.gripperButton.Enable = 'off';
                        app.GripperLabel.FontColor = [0.15,0.15,0.15];
                        app.gripperState.FontColor = [0.65,0.65,0.65];
                        app.gripperState.Value = 'ABIERTO';
                        app.gripperButton.Value = false;
                        app.joint1State.Value = '';
                        app.joint2State.Value = '';
                        app.joint3State.Value = '';
                        app.joint4State.Value = '';
                        app.xState.Value = '';
                        app.yState.Value = '';
                        app.zState.Value = '';
                        app.CargandoLabel.Text = 'Seleccione modo de operación';
                        break;
                    end
                end 
                end
                app.resetButton.Enable = 'off';
            end
            if(value == 0)
                app.stopButton.Value = 1;
                app.Estado1.Value = 'PARADA';
                app.unoButton.Value = 0;
                app.dosButton.Value = 0;
                app.tresButton.Value = 0;
                app.AUTOMTICOButton.Value = 0;
                app.MANUALButton.Value = 0;
                app.Estado2.Value = '';
                app.autoState.Visible = 'off';
                app.autoState.Value = '';
                app.startButton.Enable = 'off';
                app.AUTOMTICOButton.Enable = 'on';
                app.MANUALButton.Enable = 'on';
                app.gripperButton.Enable = 'off';
                app.GripperLabel.FontColor = [0.15,0.15,0.15];
                app.gripperState.FontColor = [0.65,0.65,0.65];
                app.gripperState.Value = 'ABIERTO';
                app.gripperButton.Value = false;
                app.joint1State.Value = '';
                app.joint2State.Value = '';
                app.joint3State.Value = '';
                app.joint4State.Value = '';
                app.xState.Value = '';
                app.yState.Value = '';
                app.zState.Value = '';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Value changed function: unoButton
        function unoButtonValueChanged(app, event)
            value = app.unoButton.Value;
            if(value == 1)
                app.autoState.Value = '1';
                app.dosButton.Value = 0;
                app.tresButton.Value = 0;
                if(app.CONECTARButton.Value == 1)
                    app.startButton.Enable = 'on';
                end
                app.CargandoLabel.Text = 'Listo para usarse';
            end
            if(value == 0)
                app.autoState.Value = '';
                app.startButton.Enable = 'off';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Value changed function: dosButton
        function dosButtonValueChanged(app, event)
            value = app.dosButton.Value;
            if(value == 1)
                app.autoState.Value = '2';
                app.unoButton.Value = 0;
                app.tresButton.Value = 0;
                if(app.CONECTARButton.Value == 1)
                    app.startButton.Enable = 'on';
                end
                app.CargandoLabel.Text = 'Listo para usarse';
            end
            if(value == 0)
                app.autoState.Value = '';
                app.startButton.Enable = 'off';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Value changed function: tresButton
        function tresButtonValueChanged(app, event)
            value = app.tresButton.Value;
            if(value == 1)
                app.autoState.Value = '3';
                app.unoButton.Value = 0;
                app.dosButton.Value = 0;
                if(app.CONECTARButton.Value == 1)
                    app.startButton.Enable = 'on';
                end
                app.CargandoLabel.Text = 'Listo para usarse';
            end
            if(value == 0)
                app.autoState.Value = '';
                app.startButton.Enable = 'off';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Value changed function: gripperButton
        function gripperButtonValueChanged(app, event)
            value = app.gripperButton.Value;
            publicadores(1) = rospublisher('/Phantom_sim/joint1_position_controller/command','std_msgs/Float64');
            publicadores(2) = rospublisher('/Phantom_sim/joint2_position_controller/command','std_msgs/Float64');
            publicadores(3) = rospublisher('/Phantom_sim/joint3_position_controller/command','std_msgs/Float64');
            publicadores(4) = rospublisher('/Phantom_sim/joint4_position_controller/command','std_msgs/Float64');
            publicadores(5) = rospublisher('/Phantom_sim/joint5_position_controller/command','std_msgs/Float64');
            publicadores(6) = rospublisher('/Phantom_sim/joint6_position_controller/command','std_msgs/Float64');
            msg= rosmessage('std_msgs/Float64');
            if(value == 1)
                app.gripperState.Value = 'CERRADO';
                msg.Data = app.closed;
                send(publicadores(5),msg)
                send(publicadores(6),msg)
            end
            if(value == 0)
                app.gripperState.Value = 'ABIERTO';
                msg.Data = app.opened;
                send(publicadores(5),msg)
                send(publicadores(6),msg)
            end
        end

        % Button pushed function: resetButton
        function resetButtonPushed(app, event)
            app.Estado1.Value = 'PARADA';
            app.startButton.Value = 0;
            app.unoButton.Value = 0;
            app.dosButton.Value = 0;
            app.tresButton.Value = 0;
            app.AUTOMTICOButton.Value = 0;
            app.unoButton.Enable = 'off';
            app.dosButton.Enable = 'off';
            app.tresButton.Enable = 'off';
            app.unoLabel.FontColor = [0.15,0.15,0.15];
            app.dosLabel.FontColor = [0.15,0.15,0.15];
            app.tresLabel.FontColor = [0.15,0.15,0.15];
            app.autoState.Visible = 'off';
            app.autoState.Value = '';
            app.MANUALButton.Value = 0;
            app.gripperButton.Enable = 'off';
            app.GripperLabel.FontColor = [0.15,0.15,0.15];
            app.gripperState.FontColor = [0.65,0.65,0.65];
            app.gripperState.Value = 'ABIERTO';
            app.gripperButton.Value = false;
            app.Estado2.Value = '';
            app.startButton.Enable = 'off';
            app.AUTOMTICOButton.Enable = 'on';
            app.MANUALButton.Enable = 'on';
            app.CargandoLabel.Text = 'Seleccione modo de operación';
        end

        % Button pushed function: closeButton
        function closeButtonPushed(app, event)
            rosshutdown;
            close(app.UIFigure)
        end

        % Value changed function: TutorialButton
        function TutorialButtonValueChanged(app, event)
            
        end

        % Value changed function: ConexinButton
        function ConexinButtonValueChanged(app, event)
            value = app.ConexinButton.Value;
            if(value == 1)
                app.ConexionPanel.Visible = 'on';
            end
            if(value == 0)
                app.ConexionPanel.Visible = 'off';
            end
        end

        % Value changed function: DirectaCheckBox
        function DirectaCheckBoxValueChanged(app, event)
            value = app.DirectaCheckBox.Value;
            if(value == 1)
                app.MquinaVirtualVMCheckBox.Value = 0;
                app.DireccinIPLocalEditField.Enable = 'off';
                app.DireccinIPLocalEditField.Value = '';
                app.DireccinIPLocalEditFieldLabel.Enable = 'off';
                app.DireccinIPRemotaEditField.Enable = 'off';
                app.DireccinIPRemotaEditField.Value = '';
                app.DireccinIPRemotaEditFieldLabel.Enable = 'off';
                app.CONECTARButton.Enable = 'on';
                app.EstadoROSLabel.Text = 'Listo para conectar';
            end
            if(value == 0)
                app.CONECTARButton.Enable = 'off';
                app.EstadoROSLabel.Text = 'Desconectado';
            end
        end

        % Value changed function: MquinaVirtualVMCheckBox
        function MquinaVirtualVMCheckBoxValueChanged(app, event)
            value = app.MquinaVirtualVMCheckBox.Value;
            if(value == 1)
                app.CONECTARButton.Enable = 'off';
                app.EstadoROSLabel.Text = 'Desconectado';
                app.DirectaCheckBox.Value = 0;
                app.DireccinIPLocalEditField.Enable = 'on';
                app.DireccinIPLocalEditFieldLabel.Enable = 'on';
            end
            if(value == 0)
                app.CONECTARButton.Enable = 'off';
                app.EstadoROSLabel.Text = 'Desconectado';
                app.DireccinIPLocalEditField.Enable = 'off';
                app.DireccinIPLocalEditFieldLabel.Enable = 'off';
                app.DireccinIPLocalEditField.Value = '';
                app.DireccinIPRemotaEditField.Enable = 'off';
                app.DireccinIPRemotaEditFieldLabel.Enable = 'off';
                app.DireccinIPRemotaEditField.Value = '';
            end
        end

        % Value changed function: CONECTARButton
        function CONECTARButtonValueChanged(app, event)
            value = app.CONECTARButton.Value;
            if(value == 1)
                app.EstadoROSLabel.Text = 'Estableciendo conexión . . .';
                app.CONECTARButton.Enable = 'off';
                app.DireccinIPLocalEditField.Enable = 'off';
                app.DireccinIPLocalEditFieldLabel.Enable = 'off';
                app.DireccinIPRemotaEditField.Enable = 'off';
                app.DireccinIPRemotaEditFieldLabel.Enable = 'off';
                app.MquinaVirtualVMCheckBox.Enable = 'off';
                app.DirectaCheckBox.Enable = 'off';
                app.DESCONECTARButton.Enable = 'on';
                app.AUTOMTICOButton.Enable = 'on';
                app.MANUALButton.Enable = 'on';
                app.resetButton.Enable = 'on';
                pause(1);
                if(app.DirectaCheckBox.Value == 1)
                    rosinit;
                end
                if(app.MquinaVirtualVMCheckBox.Value == 1)
                    setenv('ROS_MASTER_URI',strcat("http://",app.DireccinIPRemotaEditField.Value,":11311"));
                    setenv('ROS_IP',app.DireccinIPLocalEditField.Value);
                    rosinit;
                end
                pause(1);
                app.EstadoROSLabel.Text = 'Conectado';
                app.CargandoLabel.Text = 'Seleccione modo de operación';
            end
        end

        % Button pushed function: DESCONECTARButton
        function DESCONECTARButtonPushed(app, event)
            app.EstadoROSLabel.Text = 'Finalizando conexión . . .';    
            app.MquinaVirtualVMCheckBox.Enable = 'on';
            app.DirectaCheckBox.Enable = 'on';
            app.CONECTARButton.Value = 0;
            app.DirectaCheckBox.Value = 0;
            app.MquinaVirtualVMCheckBox.Value = 0;
            app.DireccinIPLocalEditField.Value = '';
            app.DireccinIPRemotaEditField.Value = '';
            app.DESCONECTARButton.Enable = 'off';
            app.AUTOMTICOButton.Enable = 'off';
            app.MANUALButton.Enable = 'off';
            app.resetButton.Enable = 'off';
            pause(1);
            rosshutdown;
            pause(1);
            app.EstadoROSLabel.Text = 'Desconectado';
            app.CargandoLabel.Text = 'Seleccione conexión';
        end

        % Value changed function: DireccinIPLocalEditField
        function DireccinIPLocalEditFieldValueChanged(app, event)
            app.DireccinIPRemotaEditField.Enable = 'on';
            app.DireccinIPRemotaEditFieldLabel.Enable = 'on';    
        end

        % Value changed function: DireccinIPRemotaEditField
        function DireccinIPRemotaEditFieldValueChanged(app, event)
            app.CONECTARButton.Enable = 'on';
            app.EstadoROSLabel.Text = 'Listo para conectar';
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.6392 0.6 0.549];
            app.UIFigure.Position = [100 100 783 618];
            app.UIFigure.Name = 'UI Figure';

            % Create Estado1
            app.Estado1 = uitextarea(app.UIFigure);
            app.Estado1.HorizontalAlignment = 'center';
            app.Estado1.FontName = 'Prototype';
            app.Estado1.FontSize = 16;
            app.Estado1.Position = [285 499 150 25];
            app.Estado1.Value = {'PARADA'};

            % Create Estado2
            app.Estado2 = uitextarea(app.UIFigure);
            app.Estado2.HorizontalAlignment = 'center';
            app.Estado2.FontName = 'Prototype';
            app.Estado2.FontSize = 16;
            app.Estado2.Position = [464 499 150 25];

            % Create camara
            app.camara = uiaxes(app.UIFigure);
            title(app.camara, 'Title')
            xlabel(app.camara, 'X')
            ylabel(app.camara, 'Y')
            app.camara.Position = [434 184 317 288];

            % Create EspaciooperacionalLabel
            app.EspaciooperacionalLabel = uilabel(app.UIFigure);
            app.EspaciooperacionalLabel.FontName = 'Prototype';
            app.EspaciooperacionalLabel.FontSize = 16;
            app.EspaciooperacionalLabel.Position = [34 222 146 22];
            app.EspaciooperacionalLabel.Text = 'Espacio operacional';

            % Create EspacioconfiguracionesLabel
            app.EspacioconfiguracionesLabel = uilabel(app.UIFigure);
            app.EspacioconfiguracionesLabel.FontName = 'Prototype';
            app.EspacioconfiguracionesLabel.FontSize = 16;
            app.EspacioconfiguracionesLabel.Position = [233 222 178 22];
            app.EspacioconfiguracionesLabel.Text = 'Espacio configuraciones';

            % Create PICKPLACELabel
            app.PICKPLACELabel = uilabel(app.UIFigure);
            app.PICKPLACELabel.FontName = 'Prototype';
            app.PICKPLACELabel.FontSize = 30;
            app.PICKPLACELabel.Position = [298 538 190 38];
            app.PICKPLACELabel.Text = 'PICK & PLACE';

            % Create EstadoLabel
            app.EstadoLabel = uilabel(app.UIFigure);
            app.EstadoLabel.FontName = 'Prototype';
            app.EstadoLabel.FontSize = 16;
            app.EstadoLabel.Position = [194 500 55 22];
            app.EstadoLabel.Text = 'Estado';

            % Create stopButton
            app.stopButton = uibutton(app.UIFigure, 'state');
            app.stopButton.ValueChangedFcn = createCallbackFcn(app, @stopButtonValueChanged, true);
            app.stopButton.Icon = 'off.png';
            app.stopButton.IconAlignment = 'center';
            app.stopButton.Text = '';
            app.stopButton.BackgroundColor = [0.6431 0.6 0.549];
            app.stopButton.Position = [111 95 59 58];
            app.stopButton.Value = true;

            % Create startButton
            app.startButton = uibutton(app.UIFigure, 'state');
            app.startButton.ValueChangedFcn = createCallbackFcn(app, @startButtonValueChanged, true);
            app.startButton.Enable = 'off';
            app.startButton.Icon = 'on.png';
            app.startButton.IconAlignment = 'center';
            app.startButton.Text = '';
            app.startButton.BackgroundColor = [0.6431 0.6 0.549];
            app.startButton.Position = [110 24 63 62];

            % Create AUTOMTICOButton
            app.AUTOMTICOButton = uibutton(app.UIFigure, 'state');
            app.AUTOMTICOButton.ValueChangedFcn = createCallbackFcn(app, @AUTOMTICOButtonValueChanged, true);
            app.AUTOMTICOButton.Enable = 'off';
            app.AUTOMTICOButton.Text = 'AUTOMÁTICO';
            app.AUTOMTICOButton.BackgroundColor = [0.8549 0.8353 0.8235];
            app.AUTOMTICOButton.FontName = 'Prototype';
            app.AUTOMTICOButton.FontSize = 14;
            app.AUTOMTICOButton.Position = [265 104 102 41];

            % Create MANUALButton
            app.MANUALButton = uibutton(app.UIFigure, 'state');
            app.MANUALButton.ValueChangedFcn = createCallbackFcn(app, @MANUALButtonValueChanged, true);
            app.MANUALButton.Enable = 'off';
            app.MANUALButton.Text = 'MANUAL';
            app.MANUALButton.BackgroundColor = [0.8549 0.8353 0.8235];
            app.MANUALButton.FontName = 'Prototype';
            app.MANUALButton.FontSize = 14;
            app.MANUALButton.Position = [266 37 100 41];

            % Create unoButton
            app.unoButton = uibutton(app.UIFigure, 'state');
            app.unoButton.ValueChangedFcn = createCallbackFcn(app, @unoButtonValueChanged, true);
            app.unoButton.Enable = 'off';
            app.unoButton.Icon = 'cuad.png';
            app.unoButton.Text = '';
            app.unoButton.BackgroundColor = [0.6431 0.6 0.549];
            app.unoButton.Position = [415 95 62 58];

            % Create dosButton
            app.dosButton = uibutton(app.UIFigure, 'state');
            app.dosButton.ValueChangedFcn = createCallbackFcn(app, @dosButtonValueChanged, true);
            app.dosButton.Enable = 'off';
            app.dosButton.Icon = 'tria.png';
            app.dosButton.Text = '';
            app.dosButton.BackgroundColor = [0.6431 0.6 0.549];
            app.dosButton.Position = [510 95 62 58];

            % Create tresButton
            app.tresButton = uibutton(app.UIFigure, 'state');
            app.tresButton.ValueChangedFcn = createCallbackFcn(app, @tresButtonValueChanged, true);
            app.tresButton.Enable = 'off';
            app.tresButton.Icon = 'circ.png';
            app.tresButton.Text = '';
            app.tresButton.BackgroundColor = [0.6431 0.6 0.549];
            app.tresButton.Position = [605 95 63 58];

            % Create gripperButton
            app.gripperButton = uibutton(app.UIFigure, 'state');
            app.gripperButton.ValueChangedFcn = createCallbackFcn(app, @gripperButtonValueChanged, true);
            app.gripperButton.Enable = 'off';
            app.gripperButton.Icon = 'equ.png';
            app.gripperButton.Text = '';
            app.gripperButton.BackgroundColor = [0.6431 0.6 0.549];
            app.gripperButton.Position = [509 28 62 58];

            % Create gripperState
            app.gripperState = uitextarea(app.UIFigure);
            app.gripperState.HorizontalAlignment = 'center';
            app.gripperState.FontName = 'Prototype';
            app.gripperState.FontSize = 16;
            app.gripperState.FontColor = [0.651 0.651 0.651];
            app.gripperState.Position = [594 37 87 25];
            app.gripperState.Value = {'ABIERTO'};

            % Create GripperLabel
            app.GripperLabel = uilabel(app.UIFigure);
            app.GripperLabel.FontName = 'Prototype';
            app.GripperLabel.FontSize = 16;
            app.GripperLabel.FontColor = [0.149 0.149 0.149];
            app.GripperLabel.Position = [611 64 55 22];
            app.GripperLabel.Text = 'Gripper';

            % Create resetButton
            app.resetButton = uibutton(app.UIFigure, 'push');
            app.resetButton.ButtonPushedFcn = createCallbackFcn(app, @resetButtonPushed, true);
            app.resetButton.Icon = 'reset.png';
            app.resetButton.BackgroundColor = [0.6392 0.6 0.549];
            app.resetButton.Enable = 'off';
            app.resetButton.Position = [187 75 28 28];
            app.resetButton.Text = '';

            % Create joint1State
            app.joint1State = uitextarea(app.UIFigure);
            app.joint1State.HorizontalAlignment = 'center';
            app.joint1State.FontName = 'Prototype';
            app.joint1State.FontSize = 16;
            app.joint1State.Position = [310 407 74 25];

            % Create joint2State
            app.joint2State = uitextarea(app.UIFigure);
            app.joint2State.HorizontalAlignment = 'center';
            app.joint2State.FontName = 'Prototype';
            app.joint2State.FontSize = 16;
            app.joint2State.Position = [310 361 74 25];

            % Create joint3State
            app.joint3State = uitextarea(app.UIFigure);
            app.joint3State.HorizontalAlignment = 'center';
            app.joint3State.FontName = 'Prototype';
            app.joint3State.FontSize = 16;
            app.joint3State.Position = [309 314 75 25];

            % Create joint4State
            app.joint4State = uitextarea(app.UIFigure);
            app.joint4State.HorizontalAlignment = 'center';
            app.joint4State.FontName = 'Prototype';
            app.joint4State.FontSize = 16;
            app.joint4State.Position = [310 267 75 25];

            % Create Joint1Label
            app.Joint1Label = uilabel(app.UIFigure);
            app.Joint1Label.FontName = 'Prototype';
            app.Joint1Label.FontSize = 16;
            app.Joint1Label.Position = [251 408 48 22];
            app.Joint1Label.Text = 'Joint 1';

            % Create Joint2Label
            app.Joint2Label = uilabel(app.UIFigure);
            app.Joint2Label.FontName = 'Prototype';
            app.Joint2Label.FontSize = 16;
            app.Joint2Label.Position = [248 362 53 22];
            app.Joint2Label.Text = 'Joint 2';

            % Create Joint3Label
            app.Joint3Label = uilabel(app.UIFigure);
            app.Joint3Label.FontName = 'Prototype';
            app.Joint3Label.FontSize = 16;
            app.Joint3Label.Position = [248 315 54 22];
            app.Joint3Label.Text = 'Joint 3';

            % Create Joint4Label
            app.Joint4Label = uilabel(app.UIFigure);
            app.Joint4Label.FontName = 'Prototype';
            app.Joint4Label.FontSize = 16;
            app.Joint4Label.Position = [248 268 54 22];
            app.Joint4Label.Text = 'Joint 4';

            % Create xState
            app.xState = uitextarea(app.UIFigure);
            app.xState.HorizontalAlignment = 'center';
            app.xState.FontName = 'Prototype';
            app.xState.FontSize = 16;
            app.xState.Position = [82 383 74 25];

            % Create yState
            app.yState = uitextarea(app.UIFigure);
            app.yState.HorizontalAlignment = 'center';
            app.yState.FontName = 'Prototype';
            app.yState.FontSize = 16;
            app.yState.Position = [82 337 74 25];

            % Create zState
            app.zState = uitextarea(app.UIFigure);
            app.zState.HorizontalAlignment = 'center';
            app.zState.FontName = 'Prototype';
            app.zState.FontSize = 16;
            app.zState.Position = [81 290 75 25];

            % Create XLabel
            app.XLabel = uilabel(app.UIFigure);
            app.XLabel.FontName = 'Prototype';
            app.XLabel.FontSize = 16;
            app.XLabel.Position = [57 384 25 22];
            app.XLabel.Text = 'X';

            % Create YLabel
            app.YLabel = uilabel(app.UIFigure);
            app.YLabel.FontName = 'Prototype';
            app.YLabel.FontSize = 16;
            app.YLabel.Position = [57 338 25 22];
            app.YLabel.Text = 'Y';

            % Create ZLabel
            app.ZLabel = uilabel(app.UIFigure);
            app.ZLabel.FontName = 'Prototype';
            app.ZLabel.FontSize = 16;
            app.ZLabel.Position = [58 291 25 22];
            app.ZLabel.Text = 'Z';

            % Create closeButton
            app.closeButton = uibutton(app.UIFigure, 'push');
            app.closeButton.ButtonPushedFcn = createCallbackFcn(app, @closeButtonPushed, true);
            app.closeButton.Icon = 'close.png';
            app.closeButton.BackgroundColor = [0.651 0.651 0.651];
            app.closeButton.Position = [757 590 29 29];
            app.closeButton.Text = '';

            % Create TutorialButton
            app.TutorialButton = uibutton(app.UIFigure, 'state');
            app.TutorialButton.ValueChangedFcn = createCallbackFcn(app, @TutorialButtonValueChanged, true);
            app.TutorialButton.Enable = 'off';
            app.TutorialButton.Text = 'Tutorial';
            app.TutorialButton.FontName = 'Prototype';
            app.TutorialButton.FontSize = 14;
            app.TutorialButton.Position = [1 595 67 24];

            % Create ConexinButton
            app.ConexinButton = uibutton(app.UIFigure, 'state');
            app.ConexinButton.ValueChangedFcn = createCallbackFcn(app, @ConexinButtonValueChanged, true);
            app.ConexinButton.Text = 'Conexión';
            app.ConexinButton.FontName = 'Prototype';
            app.ConexinButton.FontSize = 14;
            app.ConexinButton.Position = [67 595 73 24];

            % Create autoState
            app.autoState = uitextarea(app.UIFigure);
            app.autoState.HorizontalAlignment = 'center';
            app.autoState.FontName = 'Prototype';
            app.autoState.FontSize = 16;
            app.autoState.Visible = 'off';
            app.autoState.Position = [657 499 35 25];

            % Create CargandoLabel
            app.CargandoLabel = uilabel(app.UIFigure);
            app.CargandoLabel.FontName = 'Prototype';
            app.CargandoLabel.FontSize = 14;
            app.CargandoLabel.FontAngle = 'italic';
            app.CargandoLabel.Position = [155 596 457 22];
            app.CargandoLabel.Text = 'Cargando . . .';

            % Create unoLabel
            app.unoLabel = uilabel(app.UIFigure);
            app.unoLabel.FontName = 'Prototype';
            app.unoLabel.FontSize = 14;
            app.unoLabel.FontAngle = 'italic';
            app.unoLabel.FontColor = [0.149 0.149 0.149];
            app.unoLabel.Position = [476 95 17 22];
            app.unoLabel.Text = '1';

            % Create dosLabel
            app.dosLabel = uilabel(app.UIFigure);
            app.dosLabel.FontName = 'Prototype';
            app.dosLabel.FontSize = 14;
            app.dosLabel.FontAngle = 'italic';
            app.dosLabel.FontColor = [0.149 0.149 0.149];
            app.dosLabel.Position = [570 95 25 22];
            app.dosLabel.Text = '2';

            % Create tresLabel
            app.tresLabel = uilabel(app.UIFigure);
            app.tresLabel.FontName = 'Prototype';
            app.tresLabel.FontSize = 14;
            app.tresLabel.FontAngle = 'italic';
            app.tresLabel.FontColor = [0.149 0.149 0.149];
            app.tresLabel.Position = [667 95 25 22];
            app.tresLabel.Text = '3';

            % Create ConexionPanel
            app.ConexionPanel = uipanel(app.UIFigure);
            app.ConexionPanel.Visible = 'off';
            app.ConexionPanel.Position = [26 24 732 500];

            % Create CONEXINROSLabel
            app.CONEXINROSLabel = uilabel(app.ConexionPanel);
            app.CONEXINROSLabel.FontName = 'Prototype';
            app.CONEXINROSLabel.FontSize = 18;
            app.CONEXINROSLabel.Position = [302 452 130 23];
            app.CONEXINROSLabel.Text = 'CONEXIÓN ROS';

            % Create DirectaCheckBox
            app.DirectaCheckBox = uicheckbox(app.ConexionPanel);
            app.DirectaCheckBox.ValueChangedFcn = createCallbackFcn(app, @DirectaCheckBoxValueChanged, true);
            app.DirectaCheckBox.Text = 'Directa';
            app.DirectaCheckBox.FontName = 'Prototype';
            app.DirectaCheckBox.FontSize = 14;
            app.DirectaCheckBox.Position = [176 339 66 22];

            % Create SeleccioneunaopcinLabel
            app.SeleccioneunaopcinLabel = uilabel(app.ConexionPanel);
            app.SeleccioneunaopcinLabel.FontName = 'Prototype';
            app.SeleccioneunaopcinLabel.FontSize = 14;
            app.SeleccioneunaopcinLabel.Position = [176 384 147 22];
            app.SeleccioneunaopcinLabel.Text = 'Seleccione una opción:';

            % Create MquinaVirtualVMCheckBox
            app.MquinaVirtualVMCheckBox = uicheckbox(app.ConexionPanel);
            app.MquinaVirtualVMCheckBox.ValueChangedFcn = createCallbackFcn(app, @MquinaVirtualVMCheckBoxValueChanged, true);
            app.MquinaVirtualVMCheckBox.Text = 'Máquina Virtual (VM)';
            app.MquinaVirtualVMCheckBox.FontName = 'Prototype';
            app.MquinaVirtualVMCheckBox.FontSize = 14;
            app.MquinaVirtualVMCheckBox.Position = [176 293 150 22];

            % Create CONECTARButton
            app.CONECTARButton = uibutton(app.ConexionPanel, 'state');
            app.CONECTARButton.ValueChangedFcn = createCallbackFcn(app, @CONECTARButtonValueChanged, true);
            app.CONECTARButton.Enable = 'off';
            app.CONECTARButton.Text = 'CONECTAR';
            app.CONECTARButton.FontName = 'Prototype';
            app.CONECTARButton.FontSize = 16;
            app.CONECTARButton.Position = [222 120 100 27];

            % Create DESCONECTARButton
            app.DESCONECTARButton = uibutton(app.ConexionPanel, 'push');
            app.DESCONECTARButton.ButtonPushedFcn = createCallbackFcn(app, @DESCONECTARButtonPushed, true);
            app.DESCONECTARButton.FontName = 'Prototype';
            app.DESCONECTARButton.FontSize = 16;
            app.DESCONECTARButton.Enable = 'off';
            app.DESCONECTARButton.Position = [413 120 124 27];
            app.DESCONECTARButton.Text = 'DESCONECTAR';

            % Create DireccinIPLocalEditFieldLabel
            app.DireccinIPLocalEditFieldLabel = uilabel(app.ConexionPanel);
            app.DireccinIPLocalEditFieldLabel.HorizontalAlignment = 'right';
            app.DireccinIPLocalEditFieldLabel.FontName = 'Prototype';
            app.DireccinIPLocalEditFieldLabel.FontSize = 14;
            app.DireccinIPLocalEditFieldLabel.Enable = 'off';
            app.DireccinIPLocalEditFieldLabel.Position = [188 246 114 22];
            app.DireccinIPLocalEditFieldLabel.Text = 'Dirección IP Local';

            % Create DireccinIPLocalEditField
            app.DireccinIPLocalEditField = uieditfield(app.ConexionPanel, 'text');
            app.DireccinIPLocalEditField.ValueChangedFcn = createCallbackFcn(app, @DireccinIPLocalEditFieldValueChanged, true);
            app.DireccinIPLocalEditField.FontName = 'Prototype';
            app.DireccinIPLocalEditField.FontSize = 14;
            app.DireccinIPLocalEditField.Enable = 'off';
            app.DireccinIPLocalEditField.Position = [317 246 100 22];

            % Create EstadoROSLabel
            app.EstadoROSLabel = uilabel(app.ConexionPanel);
            app.EstadoROSLabel.FontName = 'Prototype';
            app.EstadoROSLabel.FontSize = 14;
            app.EstadoROSLabel.FontAngle = 'italic';
            app.EstadoROSLabel.Position = [264 76 215 22];
            app.EstadoROSLabel.Text = 'Desconectado';

            % Create DireccinIPRemotaEditFieldLabel
            app.DireccinIPRemotaEditFieldLabel = uilabel(app.ConexionPanel);
            app.DireccinIPRemotaEditFieldLabel.HorizontalAlignment = 'right';
            app.DireccinIPRemotaEditFieldLabel.FontName = 'Prototype';
            app.DireccinIPRemotaEditFieldLabel.FontSize = 14;
            app.DireccinIPRemotaEditFieldLabel.Enable = 'off';
            app.DireccinIPRemotaEditFieldLabel.Position = [188 198 130 22];
            app.DireccinIPRemotaEditFieldLabel.Text = 'Dirección IP Remota';

            % Create DireccinIPRemotaEditField
            app.DireccinIPRemotaEditField = uieditfield(app.ConexionPanel, 'text');
            app.DireccinIPRemotaEditField.ValueChangedFcn = createCallbackFcn(app, @DireccinIPRemotaEditFieldValueChanged, true);
            app.DireccinIPRemotaEditField.FontName = 'Prototype';
            app.DireccinIPRemotaEditField.FontSize = 14;
            app.DireccinIPRemotaEditField.Enable = 'off';
            app.DireccinIPRemotaEditField.Position = [333 198 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = picknplace_def

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end