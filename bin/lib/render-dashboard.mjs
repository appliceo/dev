#!/usr/bin/env node
// Render a static dashboard from test-results/last-run.json. Pure FP, no deps.
//
// Usage: node render-dashboard.mjs <input-json> <output-html>

import fs from 'node:fs'
import path from 'node:path'

const [, , inputPath, outputPath] = process.argv
if (!inputPath || !outputPath) {
  console.error('Usage: render-dashboard.mjs <input-json> <output-html>')
  process.exit(2)
}

const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'))
const outDir = path.dirname(outputPath)

// Per-suite links to detail pages produced by each runner.
const reportLinks = (suite) => {
  const base = `${suite}/`
  const links = []
  if (fs.existsSync(path.join(outDir, suite, 'playwright-report', 'index.html'))) {
    links.push({ label: 'Playwright report', href: `${base}playwright-report/index.html` })
  }
  if (fs.existsSync(path.join(outDir, suite, 'coverage', 'index.html'))) {
    links.push({ label: 'Coverage', href: `${base}coverage/index.html` })
  }
  if (fs.existsSync(path.join(outDir, suite, 'run.log'))) {
    links.push({ label: 'Run log', href: `${base}run.log` })
  }
  return links
}

const escapeHtml = (s) =>
  String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')

const statusBadge = (status) => {
  if (status === 'pass') return '<span class="badge pass">PASS</span>'
  if (status === 'fail') return '<span class="badge fail">FAIL</span>'
  return '<span class="badge skip">SKIP</span>'
}

const renderSuiteRow = (suite, info) => {
  const links = reportLinks(suite)
  const linksHtml = links.length
    ? links.map((l) => `<a href="${escapeHtml(l.href)}">${escapeHtml(l.label)}</a>`).join(' · ')
    : '<span class="muted">(no reports)</span>'

  return `
        <tr class="${info.status}">
          <td><strong>${escapeHtml(suite)}</strong></td>
          <td>${statusBadge(info.status)}</td>
          <td>${escapeHtml(info.summary)}</td>
          <td>${linksHtml}</td>
        </tr>`
}

const suiteRows = Object.entries(data.suites)
  .map(([suite, info]) => renderSuiteRow(suite, info))
  .join('')

const overallStatus = Object.values(data.suites).some((s) => s.status === 'fail')
  ? 'FAIL'
  : 'PASS'

const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Appliceo — test results</title>
  <style>
    :root {
      color-scheme: light dark;
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    body { max-width: 900px; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
    h1 { margin: 0 0 .25rem; }
    .meta { color: #666; font-size: .9rem; margin-bottom: 2rem; }
    .overall { font-size: 1.5rem; padding: .5rem 1rem; border-radius: 6px; display: inline-block; margin: 1rem 0; }
    .overall.PASS { background: #d1fae5; color: #065f46; }
    .overall.FAIL { background: #fee2e2; color: #991b1b; }
    table { width: 100%; border-collapse: collapse; }
    th, td { text-align: left; padding: .75rem .5rem; border-bottom: 1px solid #e5e7eb; vertical-align: top; }
    th { font-weight: 600; color: #374151; background: #f9fafb; }
    tr.pass td:first-child { border-left: 3px solid #10b981; }
    tr.fail td:first-child { border-left: 3px solid #ef4444; }
    tr.skip td:first-child { border-left: 3px solid #9ca3af; }
    .badge { display: inline-block; padding: .15rem .5rem; border-radius: 4px; font-size: .8rem; font-weight: 600; }
    .badge.pass { background: #d1fae5; color: #065f46; }
    .badge.fail { background: #fee2e2; color: #991b1b; }
    .badge.skip { background: #f3f4f6; color: #4b5563; }
    a { color: #2563eb; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .muted { color: #9ca3af; font-size: .85rem; }
    .footer { color: #9ca3af; font-size: .8rem; margin-top: 2rem; }
    @media (prefers-color-scheme: dark) {
      body { background: #111; color: #e5e7eb; }
      th { background: #1f2937; color: #d1d5db; }
      th, td { border-bottom-color: #374151; }
      .overall.PASS { background: #064e3b; color: #a7f3d0; }
      .overall.FAIL { background: #7f1d1d; color: #fecaca; }
      .badge.pass { background: #064e3b; color: #a7f3d0; }
      .badge.fail { background: #7f1d1d; color: #fecaca; }
      .badge.skip { background: #1f2937; color: #9ca3af; }
      a { color: #60a5fa; }
      .meta, .muted, .footer { color: #6b7280; }
    }
  </style>
</head>
<body>
  <h1>Appliceo — test results</h1>
  <div class="meta">Generated ${escapeHtml(data.generatedAt)}${data.coverage ? ' · with coverage' : ''}</div>

  <div class="overall ${overallStatus}">${overallStatus}</div>

  <table>
    <thead>
      <tr>
        <th>Suite</th>
        <th>Status</th>
        <th>Summary</th>
        <th>Reports</th>
      </tr>
    </thead>
    <tbody>${suiteRows}
    </tbody>
  </table>

  <p class="footer">Re-run any subset with <code>bin/run-tests.sh --api --coverage</code>. Refresh dashboard alone with <code>bin/run-tests.sh --report</code>.</p>
</body>
</html>
`

fs.writeFileSync(outputPath, html)
console.log(`Wrote dashboard: ${outputPath}`)
