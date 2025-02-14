within TRANSFORM.Fluid.Pipes;
model GenericPipe_wWall_wTraceMass
  import Modelica.Fluid.Types.Dynamics;
  import TRANSFORM.Math.linspace_2Dedge;
  import TRANSFORM.Math.linspaceRepeat_2Dedge;
  outer TRANSFORM.Fluid.SystemTF systemTF;
  //extends TRANSFORM.Fluid.Pipes.ClosureModels.Geometry.PipeWithWallIcons;
  // Geometry Model
  replaceable model Geometry =
      TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.Pipe_Wall.StraightPipe
    constrainedby TRANSFORM.Fluid.ClosureRelations.Geometry.Models.DistributedVolume_1D.Pipe_Wall.PartialPipeWithWall
    "Geometry" annotation (Dialog(group="Geometry"), choicesAllMatching=true);
  Geometry geometry
    annotation (Placement(transformation(extent={{-78,82},{-62,98}})));
  extends BaseClasses.GenericPipe_wTraceMass_Record_multiSurface(
    final nV=pipe.geometry.nV,
    use_HeatTransfer=true,
    use_TraceMassTransfer=true);
  input SI.Acceleration g_n=Modelica.Constants.g_n "Gravitational acceleration"
    annotation (Dialog(tab="Advanced", group="Inputs"));
  replaceable package Material = TRANSFORM.Media.Solids.SS316 constrainedby TRANSFORM.Media.Interfaces.Solids.PartialAlloy
                                            "Wall material properties"
    annotation (choicesAllMatching=true);
  parameter Boolean counterCurrent=false "Swap wall vector order";
  parameter Boolean use_HeatTransferOuter=false
    "= true to use outer wall heat port" annotation (Dialog(group="Heat Transfer"));
  parameter Boolean use_TraceMassTransferOuter=false
    "= true to use outer wall mass port" annotation (Dialog(group="Trace Mass Transfer"));
  final parameter Integer nVs[2](min=1) = {geometry.nR,geometry.nZ}
    "Number of discrete volumes";
  // Initialization: Wall
  parameter Dynamics energyDynamics_wall=Dynamics.DynamicFreeInitial
    "Formulation of energy balances"
    annotation (Dialog(tab="Advanced", group="Dynamics"));
  parameter SI.Temperature Ts_start_wall[nVs[1],nVs[2]]=linspace_2Dedge(
      T_a1_start,
      T_b1_start,
      T_a2_start,
      T_b2_start,
      nVs[1],
      nVs[2],
      {exposeState_outerWall,exposeState_a,true,exposeState_b}) "Temperature"
    annotation (Dialog(tab="Initialization: Wall", group="Start Value: Temperature"));
  parameter SI.Temperature T_a1_start=Material.T_reference
    "Temperature at port a1" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Temperature"));
  parameter SI.Temperature T_b1_start=T_a1_start "Temperature at port b1"
    annotation (Dialog(tab="Initialization: Wall", group="Start Value: Temperature"));
  parameter SI.Temperature T_a2_start=Material.T_reference
    "Temperature at port a2" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Temperature"));
  parameter SI.Temperature T_b2_start=T_a2_start "Temperature at port b2"
    annotation (Dialog(tab="Initialization: Wall", group="Start Value: Temperature"));
  // Advanced
  parameter Boolean exposeState_outerWall=false
    "=true, T is calculated at outer wall else Q_flow" annotation (Dialog(group=
         "Model Structure", tab="Advanced"));
  replaceable model InternalHeatModel_wall =
      TRANSFORM.HeatAndMassTransfer.DiscritizedModels.BaseClasses.Dimensions_2.GenericHeatGeneration
    constrainedby TRANSFORM.HeatAndMassTransfer.DiscritizedModels.BaseClasses.Dimensions_2.PartialInternalHeatGeneration
    "Internal heat generation" annotation (Dialog(group="Heat Transfer"),
      choicesAllMatching=true);
  final parameter Integer nC=Medium.nC "Number of trace substances";
  // Initialization: Wall
  parameter Dynamics traceDynamics_wall=energyDynamics_wall
    "Formulation of trace substance balances"
    annotation (Dialog(tab="Advanced", group="Dynamics"));
  parameter SI.Concentration Cs_start_wall[nVs[1],nVs[2],nC]=
      linspaceRepeat_2Dedge(
      C_a1_start_wall,
      C_b1_start_wall,
      C_a2_start_wall,
      C_b2_start_wall,
      nVs[1],
      nVs[2],
      {exposeState_outerWall,exposeState_a,true,exposeState_b})
    "Trace substance concentration" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Concentration"));
  parameter SI.Concentration C_a1_start_wall[nC]=fill(0, nC)
    "Concentration at portM_a1" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Concentration"));
  parameter SI.Concentration C_b1_start_wall[nC]=C_a1_start_wall
    "Concentration at portM_b1" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Concentration"));
  parameter SI.Concentration C_a2_start_wall[nC]=fill(0, nC)
    "Concentration at portM_a2" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Concentration"));
  parameter SI.Concentration C_b2_start_wall[nC]=C_a2_start_wall
    "Concentration at portM_b2" annotation (Dialog(tab="Initialization: Wall",
        group="Start Value: Concentration"));
  replaceable model InternalMassModel_wall =
      TRANSFORM.HeatAndMassTransfer.DiscritizedModels.BaseClasses.Dimensions_2.GenericMassGeneration
    constrainedby TRANSFORM.HeatAndMassTransfer.DiscritizedModels.BaseClasses.Dimensions_2.PartialInternalMassGeneration
    "Internal mass generation" annotation (Dialog(group="Trace Mass Transfer"),
      choicesAllMatching=true);
  replaceable model DiffusionCoeff_wall =
      TRANSFORM.Media.ClosureModels.MassDiffusionCoefficient.Models.GenericCoefficient    constrainedby
    TRANSFORM.Media.ClosureModels.MassDiffusionCoefficient.Models.PartialMassDiffusionCoefficient
    "Diffusion Coefficient" annotation (Dialog(group="Trace Mass Transfer"),
      choicesAllMatching=true);
  parameter Real nb[nV,nC]=fill(
      1,
      nV,
      nC) "Exponential parameter of (C/kb)^nb (i.e., if Sievert than nb = 2)"
    annotation (Dialog(group="Trace Mass Transfer"));
  input Real Ka[nV,nC]=fill(
      1,
      nV,
      nC) "Fluid side solubility coefficient (i.e., Henry/Sievert)"
    annotation (Dialog(group="Trace Mass Transfer"));
  input Real Kb[nV,nC]=fill(
      1,
      nV,
      nC) "Wall side solubility coefficient (i.e., Henry/Sievert)"
    annotation (Dialog(group="Trace Mass Transfer"));
  GenericPipe_MultiTransferSurface
              pipe(
    nParallel=nParallel,
    redeclare package Medium = Medium,
    redeclare model FlowModel = FlowModel,
    use_HeatTransfer=use_HeatTransfer,
    redeclare model HeatTransfer = HeatTransfer,
    redeclare model InternalHeatGen = InternalHeatGen,
    use_TraceMassTransfer=use_TraceMassTransfer,
    redeclare model TraceMassTransfer = TraceMassTransfer,
    redeclare model InternalTraceGen = InternalTraceGen,
    energyDynamics=energyDynamics,
    massDynamics=massDynamics,
    traceDynamics=traceDynamics,
    ps_start=ps_start,
    use_Ts_start=use_Ts_start,
    Ts_start=Ts_start,
    hs_start=hs_start,
    Xs_start=Xs_start,
    Cs_start=Cs_start,
    p_a_start=p_a_start,
    p_b_start=p_b_start,
    T_a_start=T_a_start,
    T_b_start=T_b_start,
    h_a_start=h_a_start,
    h_b_start=h_b_start,
    X_a_start=X_a_start,
    X_b_start=X_b_start,
    C_a_start=C_a_start,
    C_b_start=C_b_start,
    m_flow_a_start=m_flow_a_start,
    m_flow_b_start=m_flow_b_start,
    m_flows_start=m_flows_start,
    momentumDynamics=momentumDynamics,
    exposeState_a=exposeState_a,
    exposeState_b=exposeState_b,
    g_n=g_n,
    useInnerPortProperties=useInnerPortProperties,
    useLumpedPressure=useLumpedPressure,
    lumpPressureAt=lumpPressureAt,
    redeclare model Geometry = Geometry,
    calc_Wb=calc_Wb)
    annotation (Placement(transformation(extent={{-10,-90},{10,-70}})));
  HeatAndMassTransfer.DiscritizedModels.HMTransfer_2D wall(
    nC=nC,
    redeclare package Material = Material,
    nParallel=nParallel,
    redeclare model InternalHeatModel = InternalHeatModel_wall,
    redeclare model DiffusionCoeff = DiffusionCoeff_wall,
    redeclare model InternalMassModel = InternalMassModel_wall,
    energyDynamics=energyDynamics_wall,
    Ts_start=Ts_start_wall,
    T_a1_start=T_a1_start,
    T_b1_start=T_b1_start,
    T_a2_start=T_a2_start,
    T_b2_start=T_b2_start,
    traceDynamics=traceDynamics_wall,
    Cs_start=Cs_start_wall,
    C_a1_start=C_a1_start_wall,
    C_b1_start=C_b1_start_wall,
    C_a2_start=C_a2_start_wall,
    C_b2_start=C_b2_start_wall,
    exposeState_b1=exposeState_outerWall,
    exposeState_a2=exposeState_a,
    exposeState_b2=exposeState_b,
    redeclare model Geometry =
        HeatAndMassTransfer.ClosureRelations.Geometry.Models.Cylinder_2D_r_z (
        nR=geometry.nR,
        nZ=geometry.nZ,
        r_outer=wall.geometry.r_inner + sum(geometry.ths_wall)/geometry.nV,
        length_z=sum(geometry.dlengths),
        drs=geometry.drs,
        dzs=geometry.dzs,
        r_inner=geometry.r_inner),
    exposeState_a1=false)                                        annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={0,-20})));
  Interfaces.FluidPort_Flow port_a(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}}),
        iconTransformation(extent={{-110,-10},{-90,10}})));
  Interfaces.FluidPort_Flow port_b(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{90,-10},{110,10}}),
        iconTransformation(extent={{90,-10},{110,10}})));
  HeatAndMassTransfer.BoundaryConditions.Heat.Adiabatic adiabatic_a[geometry.nR]
    annotation (Placement(transformation(extent={{-60,-44},{-40,-24}})));
  HeatAndMassTransfer.BoundaryConditions.Heat.Adiabatic adiabatic_b[geometry.nR]
    annotation (Placement(transformation(extent={{60,-44},{40,-24}})));
  HeatAndMassTransfer.BoundaryConditions.Heat.Adiabatic adiabatic_outer[
    geometry.nZ]                                                    if not use_HeatTransferOuter
    annotation (Placement(transformation(extent={{60,-8},{40,12}})));
  HeatAndMassTransfer.BoundaryConditions.Heat.CounterFlow counterFlow(
      counterCurrent=counterCurrent, n=geometry.nZ)
                                       if use_HeatTransferOuter annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,18})));
  HeatAndMassTransfer.BoundaryConditions.Mass.AdiabaticMass adiabaticM_a[
    geometry.nR](each nC=nC)
    annotation (Placement(transformation(extent={{-60,-26},{-40,-6}})));
  HeatAndMassTransfer.BoundaryConditions.Mass.AdiabaticMass adiabaticM_b[
    geometry.nR](each nC=nC)
    annotation (Placement(transformation(extent={{60,-26},{40,-6}})));
  HeatAndMassTransfer.BoundaryConditions.Mass.AdiabaticMass adiabaticM_outer[
    geometry.nZ](each nC=nC)
                 if not use_TraceMassTransferOuter
    annotation (Placement(transformation(extent={{-60,-8},{-40,12}})));
  HeatAndMassTransfer.BoundaryConditions.Mass.CounterFlow counterFlowM(
    nC=nC,
    n=geometry.nZ,
    counterCurrent=counterCurrent) if use_TraceMassTransferOuter annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-20,18})));
  HeatAndMassTransfer.Interfaces.HeatPort_Flow heatPorts[geometry.nZ] if use_HeatTransferOuter
    annotation (Placement(transformation(extent={{-10,34},{10,54}}),
        iconTransformation(extent={{-10,40},{10,60}})));
  HeatAndMassTransfer.Interfaces.MolePort_Flow massPorts[geometry.nZ](each nC=
        nC) if use_TraceMassTransferOuter annotation (Placement(transformation(
          extent={{-50,34},{-30,54}}), iconTransformation(extent={{-50,40},{-30,
            60}})));
  HeatAndMassTransfer.BoundaryConditions.Heat.Adiabatic adiabatic_inner[
    geometry.nZ]                                                    if not use_HeatTransfer
    annotation (Placement(transformation(extent={{60,-62},{40,-42}})));
  HeatAndMassTransfer.BoundaryConditions.Mass.AdiabaticMass adiabaticM_inner[
    geometry.nZ](each nC=nC)
                 if not use_TraceMassTransfer
    annotation (Placement(transformation(extent={{-60,-62},{-40,-42}})));
  HeatAndMassTransfer.Resistances.Mass.SolubilityInterface interface[geometry.nZ](
    each nC=nC,
    nb=nb,
    Ka=Ka,
    Kb=Kb) if use_TraceMassTransfer annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-4,-62})));
  // Visualization
  parameter Boolean showName = true annotation(Dialog(tab="Visualization"));
  parameter Boolean showDesignFlowDirection = true annotation(Dialog(tab="Visualization"));
  extends TRANSFORM.Utilities.Visualizers.IconColorMap(showColors=systemTF.showColors, val_min=systemTF.val_min,val_max=systemTF.val_max, val=pipe.summary.T_effective);
  HeatAndMassTransfer.Interfaces.HeatPort_Flow heatPorts_add[geometry.nZ,
    geometry.nSurfaces - 1] if geometry.nSurfaces > 1
    annotation (Placement(transformation(extent={{20,-80},{40,-60}}),
        iconTransformation(extent={{20,-10},{40,10}})));
  HeatAndMassTransfer.Interfaces.MolePort_Flow massPorts_add[geometry.nZ,
    geometry.nSurfaces - 1](each nC=nC)  if geometry.nSurfaces > 1 annotation (Placement(transformation(
          extent={{-40,-80},{-20,-60}}), iconTransformation(extent={{-40,-10},{
            -20,10}})));
equation
  connect(port_a, pipe.port_a) annotation (Line(
      points={{-100,0},{-60,0},{-60,-80},{-10,-80}},
      color={0,127,255},
      thickness=0.5));
  connect(port_b, pipe.port_b) annotation (Line(
      points={{100,0},{100,-14},{60,-14},{60,-80},{10,-80}},
      color={0,127,255},
      thickness));
  connect(wall.port_a1, pipe.heatPorts[:,1]) annotation (Line(
      points={{0,-30},{0,-75}},
      color={191,0,0},
      thickness));
  connect(wall.portM_a2, adiabaticM_a.port) annotation (Line(
      points={{-9.8,-16},{-40,-16}},
      color={0,140,72},
      thickness));
  connect(wall.port_a2, adiabatic_a.port) annotation (Line(
      points={{-10,-20},{-20,-20},{-20,-34},{-40,-34}},
      color={191,0,0},
      thickness));
  connect(adiabaticM_b.port, wall.portM_b2) annotation (Line(
      points={{40,-16},{10,-16}},
      color={0,140,72},
      thickness));
  connect(adiabatic_b.port, wall.port_b2) annotation (Line(
      points={{40,-34},{20,-34},{20,-20},{10,-20}},
      color={191,0,0},
      thickness));
  connect(adiabaticM_outer.port, wall.portM_b1) annotation (Line(
      points={{-40,2},{-4,2},{-4,-10}},
      color={0,140,72},
      thickness));
  connect(adiabatic_outer.port, wall.port_b1) annotation (Line(
      points={{40,2},{0,2},{0,-10}},
      color={191,0,0},
      thickness));
  connect(counterFlowM.port_a, wall.portM_b1) annotation (Line(
      points={{-20,8},{-20,2},{-4,2},{-4,-10}},
      color={0,140,72},
      thickness));
  connect(counterFlow.port_a, wall.port_b1) annotation (Line(
      points={{0,8},{0,-10}},
      color={191,0,0},
      thickness));
  connect(counterFlowM.port_b, massPorts) annotation (Line(
      points={{-20,28},{-20,32},{-40,32},{-40,44}},
      color={0,140,72},
      thickness));
  connect(counterFlow.port_b, heatPorts) annotation (Line(
      points={{0,28},{0,44}},
      color={191,0,0},
      thickness));
  connect(adiabatic_inner.port, wall.port_a1) annotation (Line(
      points={{40,-52},{0,-52},{0,-30}},
      color={191,0,0},
      thickness));
  connect(adiabaticM_inner.port, wall.portM_a1) annotation (Line(
      points={{-40,-52},{-4,-52},{-4,-30}},
      color={0,140,72},
      thickness));
  connect(pipe.massPorts[:,1], interface.port_a) annotation (Line(
      points={{-4,-75},{-4,-69}},
      color={0,140,72},
      thickness));
  connect(interface.port_b, wall.portM_a1) annotation (Line(
      points={{-4,-55},{-4,-30}},
      color={0,140,72},
      thickness));
  connect(massPorts_add, pipe.massPorts[:,2:geometry.nSurfaces])
    annotation (Line(points={{-30,-70},{-4,-70},{-4,-75}}, color={0,140,72}));
  connect(heatPorts_add, pipe.heatPorts[:,2:geometry.nSurfaces])
    annotation (Line(points={{30,-70},{0,-70},{0,-75}}, color={191,0,0}));
  annotation (defaultComponentName="pipe",
Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Ellipse(
          extent={{-92,30},{-108,-30}},
          lineColor={0,127,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=exposeState_a),
        Ellipse(
          extent={{108,30},{92,-30}},
          lineColor={0,127,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=exposeState_b),
        Ellipse(
          extent={{8,30},{-8,-30}},
          lineColor={191,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=exposeState_outerWall,
          origin={0,50},
          rotation=90),
        Rectangle(
          extent={{-90,40},{90,-40}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor=DynamicSelect({0,127,255}, if showColors then dynColor else {0,127,255})),
        Ellipse(
          extent={{-65,5},{-55,-5}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-5,5},{5,-5}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{55,5},{65,-5}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-90,40},{90,32}},
          lineColor={0,0,0},
          fillColor={95,95,95},
          fillPattern=FillPattern.Backward),
        Rectangle(
          extent={{-90,-32},{90,-40}},
          lineColor={0,0,0},
          fillColor={95,95,95},
          fillPattern=FillPattern.Backward),
        Line(
          points={{30,40},{30,-40}},
          color={0,0,0},
          pattern=LinePattern.Dash),
        Line(
          points={{-30,40},{-30,-40}},
          color={0,0,0},
          pattern=LinePattern.Dash),
        Text(
          extent={{-149,-68},{151,-108}},
          lineColor={0,0,255},
          textString="%name",
          visible=DynamicSelect(true,showName)),
        Polygon(
          points={{20,-45},{60,-60},{20,-75},{20,-45}},
          lineColor={0,128,255},
          smooth=Smooth.None,
          fillColor={0,128,255},
          fillPattern=FillPattern.Solid,
          visible=DynamicSelect(true,showDesignFlowDirection)),
        Polygon(
          points={{20,-50},{50,-60},{20,-70},{20,-50}},
          lineColor={255,255,255},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=DynamicSelect(true,showDesignFlowDirection)),
        Line(
          points={{55,-60},{-60,-60}},
          color={0,128,255},
          smooth=Smooth.None,
          visible=DynamicSelect(true,showDesignFlowDirection))}),
                                 Diagram(coordinateSystem(preserveAspectRatio=false)));
end GenericPipe_wWall_wTraceMass;
