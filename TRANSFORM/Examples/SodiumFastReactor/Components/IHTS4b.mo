within TRANSFORM.Examples.SodiumFastReactor.Components;
model IHTS4b

  replaceable package Medium =
      TRANSFORM.Media.Fluids.Sodium.ConstantPropertyLiquidSodium
    "Primary heat system medium" annotation(choicesAllMatching=true);

  Fluid.Machines.Pump_SimpleMassFlow pump(m_flow_nominal=data.m_flow_IHX_IHTS,
      redeclare package Medium = Medium) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={-30,-60})));
  Fluid.Pipes.GenericPipe_MultiTransferSurface pipe_toIHX(
    T_a_start=data.T_IHX_inletIHTS,
    m_flow_a_start=data.m_flow_IHX_IHTS,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.StraightPipe
        (dimension=data.D_pipes_IHTStofromHXs, length=0.5*data.length_pipes_IHTStofromHXs),
    redeclare package Medium = Medium,
    p_a_start=400000)
    annotation (Placement(transformation(extent={{-50,-70},{-70,-50}})));

  Fluid.Pipes.GenericPipe_MultiTransferSurface pipe_fromIHX(
    T_a_start=data.T_IHX_outletIHTS,
    m_flow_a_start=data.m_flow_IHX_IHTS,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.StraightPipe
        (dimension=data.D_pipes_IHTStofromHXs, length=data.length_pipes_IHTStofromHXs),
    redeclare package Medium = Medium,
    p_a_start=300000)
    annotation (Placement(transformation(extent={{-70,30},{-50,50}})));

  Data.SFR_PHS data
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
  Fluid.Pipes.GenericPipe_withWall pipe_AHX(
    redeclare model HeatTransfer =
        Fluid.ClosureRelations.HeatTransfer.Models.DistributedPipe_1D.Nus_SinglePhase_2Region,
    use_HeatTransferOuter=true,
    m_flow_a_start=data.m_flow_IHX_IHTS,
    redeclare package Medium = Medium,
    redeclare package Material = Media.Solids.SS304,
    nParallel=3*data.nTubes_AHX,
    T_a_start=data.T_IHX_outletIHTS,
    T_b_start=data.T_IHX_inletIHTS,
    T_a2_start=data.T_IHX_inletIHTS,
    T_a1_start=data.T_IHX_inletIHTS,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.Pipe_Wall.StraightPipe
        (
        nR=3,
        dimension=data.D_tube_inner_AHX,
        length=data.length_tube_AHX,
        th_wall=data.th_tubewall_AHX,
        nV=2),
    p_a_start=250000) annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=90,
        origin={80,0})));

  Fluid.Volumes.ExpansionTank_1Port expansionTank(
    A=1,
    V0=0.001,
    level_start=1,
    h_start=data.h_start_IHTS_cold,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{12,-20},{32,0}})));
  Fluid.FittingsAndResistances.SpecifiedResistance resistance_toExpTank1(
      redeclare package Medium = Medium, R=1/data.m_flow_IHX_IHTS) annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={22,-34})));
  Fluid.Volumes.MixingVolume volume_toPump(
    redeclare model Geometry =
        Fluid.ClosureRelations.Geometry.Models.LumpedVolume.Cylinder (crossArea=
           1),
    redeclare package Medium = Medium,
    nPorts_b=2,
    nPorts_a=1,
    p_start=150000)
    annotation (Placement(transformation(extent={{46,-70},{26,-50}})));
  Fluid.Pipes.GenericPipe_MultiTransferSurface pipe_toPump(
    T_a_start=data.T_IHX_inletIHTS,
    m_flow_a_start=data.m_flow_IHX_IHTS,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.StraightPipe
        (dimension=data.D_pipes_IHTStofromHXs, length=0.5*data.length_pipes_IHTStofromHXs),
    redeclare package Medium = Medium,
    p_a_start=200000)
    annotation (Placement(transformation(extent={{70,-70},{50,-50}})));

  Fluid.FittingsAndResistances.SpecifiedResistance resistance_toPump(R=1/data.m_flow_IHX_IHTS,
      redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{0,-70},{20,-50}})));
  HeatAndMassTransfer.BoundaryConditions.Heat.HeatFlow_multi boundary_AHX(
      nPorts=pipe_AHX.geometry.nV, Q_flow=fill(-data.Qth_nominal_IHXs/
        boundary_AHX.nPorts, boundary_AHX.nPorts))
    annotation (Placement(transformation(extent={{126,-10},{106,10}})));
  Fluid.Interfaces.FluidPort_Flow port_a(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-110,-70},{-90,-50}})));
  Fluid.Interfaces.FluidPort_State port_b(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-110,30},{-90,50}})));
equation
  connect(pump.port_b, pipe_toIHX.port_a)
    annotation (Line(points={{-40,-60},{-50,-60}}, color={0,127,255}));
  connect(pipe_fromIHX.port_b, pipe_AHX.port_a)
    annotation (Line(points={{-50,40},{80,40},{80,10}}, color={0,127,255}));
  connect(pipe_toPump.port_a, pipe_AHX.port_b)
    annotation (Line(points={{70,-60},{80,-60},{80,-10}}, color={0,127,255}));
  connect(volume_toPump.port_a[1], pipe_toPump.port_b)
    annotation (Line(points={{42,-60},{50,-60}}, color={0,127,255}));
  connect(resistance_toExpTank1.port_a, volume_toPump.port_b[1]) annotation (
      Line(points={{22,-41},{22,-60.5},{30,-60.5}}, color={0,127,255}));
  connect(resistance_toPump.port_b, volume_toPump.port_b[2]) annotation (Line(
        points={{17,-60},{24,-60},{24,-59.5},{30,-59.5}}, color={0,127,255}));
  connect(resistance_toExpTank1.port_b, expansionTank.port)
    annotation (Line(points={{22,-27},{22,-18.4}}, color={0,127,255}));
  connect(resistance_toPump.port_a, pump.port_a)
    annotation (Line(points={{3,-60},{-20,-60}}, color={0,127,255}));
  connect(pipe_AHX.heatPorts, boundary_AHX.port)
    annotation (Line(points={{85,0},{106,0}}, color={191,0,0}));
  connect(pipe_fromIHX.port_a, port_b)
    annotation (Line(points={{-70,40},{-100,40}}, color={0,127,255}));
  connect(pipe_toIHX.port_b, port_a)
    annotation (Line(points={{-70,-60},{-100,-60}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.Dash),
        Rectangle(
          extent={{-62,-58},{-46,-62}},
          pattern=LinePattern.None,
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-70,-52},{-58,-56}},
          pattern=LinePattern.None,
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-10,-20},{10,-40}},
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-12,-18},{12,-30}},
          lineThickness=0.5,
          pattern=LinePattern.None,
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-20,20},{20,-20}},
          lineColor={0,0,0},
          origin={80,60},
          rotation=90),
        Line(
          points={{76,80}},
          color={28,108,200},
          thickness=0.5),
        Line(
          points={{30,102}},
          color={28,108,200},
          thickness=0.5),
        Line(points={{80,78},{80,68},{90,66},{70,62},{80,60}}, color={238,46,47}),
        Line(
          points={{0,9},{0,-1},{10,-3},{-10,-7},{0,-9}},
          color={28,108,200},
          origin={80,51},
          rotation=180),
        Rectangle(
          extent={{-20,20},{20,-20}},
          lineColor={0,0,0},
          origin={80,0},
          rotation=90),
        Line(points={{80,18},{80,8},{90,6},{70,2},{80,0}}, color={238,46,47}),
        Line(
          points={{0,9},{0,-1},{10,-3},{-10,-7},{0,-9}},
          color={28,108,200},
          origin={80,-9},
          rotation=180),
        Rectangle(
          extent={{-20,20},{20,-20}},
          lineColor={0,0,0},
          origin={80,-60},
          rotation=90),
        Line(points={{80,-42},{80,-52},{90,-54},{70,-58},{80,-60}}, color={238,
              46,47}),
        Line(
          points={{0,9},{0,-1},{10,-3},{-10,-7},{0,-9}},
          color={28,108,200},
          origin={80,-69},
          rotation=180),
        Ellipse(
          extent={{-66,-52},{-50,-68}},
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Ellipse(extent={{-10,-20},{10,-40}}, lineColor={0,0,0}),
        Line(
          points={{-60,-24}},
          pattern=LinePattern.None,
          thickness=0.5),
        Line(points={{-90,40},{22,40}}, color={238,46,47}),
        Line(points={{80,82},{80,88},{30,88},{30,54},{30,40}}, color={238,46,47}),
        Line(points={{80,22},{80,28},{30,28},{30,40},{22,40}}, color={238,46,47}),
        Line(points={{80,-38},{80,-32},{30,-32},{30,24},{30,28}}, color={238,46,
              47}),
        Line(points={{80,38},{80,32},{26,32},{26,-60},{-44,-60}}, color={28,108,
              200}),
        Line(points={{80,-22},{80,-28},{28,-28}}, color={28,108,200}),
        Line(points={{80,-82},{80,-88},{26,-88},{26,-60}}, color={28,108,200}),
        Line(points={{0,-60},{0,-42}}, color={28,108,200}),
        Line(points={{-90,-60},{-70,-60}}, color={28,108,200}),
        Ellipse(
          extent={{18,-52},{34,-68}},
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None)}),                           Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=1000));
end IHTS4b;