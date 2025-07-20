import { MoScript, registerMoScript } from './moscript';

// 1. Shipment Delay Root Cause Analyzer
const mo_DELAY_ANALYZER: MoScript = {
  id: 'mo-delay-analyze-002',
  name: 'Delay Root Cause Analyzer',
  trigger: 'onDelayDetected',
  inputs: ['shipmentData', 'events'],
  logic: ({ shipmentData, events }) => {
    // Analyze events to determine the most common root cause for delays
    const delayEvents = events.filter((e: any) => e.type === 'delay');
    const causeCounts: Record<string, number> = {};
    delayEvents.forEach((e: any) => {
      causeCounts[e.reason] = (causeCounts[e.reason] || 0) + 1;
    });
    const top = Object.entries(causeCounts).sort((a, b) => b[1] - a[1])[0];
    return { top: { reason: top?.[0], count: top?.[1] }, all: causeCounts };
  },
  voiceLine: (result) =>
    `Root cause alert: ${result.top.reason} is the main culprit behind your delays. Time to take action!`,
  sass: false
};
registerMoScript(mo_DELAY_ANALYZER);

// 2. Carbon Emission Tracker
const mo_CARBON_TRACKER: MoScript = {
  id: 'mo-carbon-track-003',
  name: 'Carbon Emission Tracker',
  trigger: 'onShipmentCompleted',
  inputs: ['shipmentData'],
  logic: ({ shipmentData }) => {
    // Sum up carbon emissions for completed shipments
    const total = shipmentData.reduce((sum: number, s: any) => sum + (s.carbonKg || 0), 0);
    return { total };
  },
  voiceLine: (result) =>
    `Your shipments released ${result.total} kg of CO₂. Plant a tree, maybe?`,
  sass: true
};
registerMoScript(mo_CARBON_TRACKER);

// 3. Lane Bottleneck Identifier
const mo_LANE_BOTTLENECK: MoScript = {
  id: 'mo-lane-bottle-004',
  name: 'Lane Bottleneck Identifier',
  trigger: 'onWeeklyOpsReview',
  inputs: ['shipmentData'],
  logic: ({ shipmentData }) => {
    // Identify lanes with the highest delay frequency
    const laneDelays: Record<string, number> = {};
    shipmentData.forEach((s: any) => {
      if (s.delayed) laneDelays[s.lane] = (laneDelays[s.lane] || 0) + 1;
    });
    const top = Object.entries(laneDelays).sort((a, b) => b[1] - a[1])[0];
    return { top: { lane: top?.[0], count: top?.[1] }, all: laneDelays };
  },
  voiceLine: (result) =>
    `Heads up: The ${result.top.lane} lane is your biggest bottleneck this week.`,
  sass: false
};
registerMoScript(mo_LANE_BOTTLENECK);

// 4. Invoice Anomaly Detector
const mo_INVOICE_ANOMALY: MoScript = {
  id: 'mo-invoice-anom-005',
  name: 'Invoice Anomaly Detector',
  trigger: 'onInvoiceReceived',
  inputs: ['invoiceData', 'historical'],
  logic: ({ invoiceData, historical }) => {
    // Flag invoices that deviate >20% from historical average
    const avg = historical.reduce((sum: number, inv: any) => sum + inv.amount, 0) / (historical.length || 1);
    const anomalies = invoiceData.filter((inv: any) => Math.abs(inv.amount - avg) / avg > 0.2);
    return { anomalies, avg };
  },
  voiceLine: (result) =>
    `${result.anomalies.length} invoices look suspicious this cycle. Double-check before paying!`,
  sass: true
};
registerMoScript(mo_INVOICE_ANOMALY);

// 5. Carrier Performance Drop Notifier
const mo_CARRIER_PERF_DROP: MoScript = {
  id: 'mo-carrier-perf-006',
  name: 'Carrier Performance Drop Notifier',
  trigger: 'onMonthlyReview',
  inputs: ['carrierStats'],
  logic: ({ carrierStats }) => {
    // Find carriers whose on-time % dropped more than 10% compared to last month
    const dropped = carrierStats.filter((c: any) => (c.lastMonthOnTime - c.thisMonthOnTime) > 10);
    return { dropped };
  },
  voiceLine: (result) =>
    result.dropped.length
      ? `Warning: ${result.dropped.map((c: any) => c.name).join(', ')} are slipping on performance.`
      : 'All carriers are holding steady this month.',
  sass: false
};
registerMoScript(mo_CARRIER_PERF_DROP);
