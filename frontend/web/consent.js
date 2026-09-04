/* ═══════════════════════════════════════════════════════════════════════════
   CreatorTools.biz — cookie consent + Google Consent Mode v2

   Loaded SYNCHRONOUSLY from <head>, before any Google tag. The consent
   defaults below must be in dataLayer before AdSense/gtag boots, otherwise
   Google will have already read storage and the defaults are pointless.

   What this does:
     • Sets Consent Mode v2 defaults — denied in the EEA/UK/CH, granted
       elsewhere. Google applies the `region` filter by IP, which is far more
       reliable than anything we can detect in the browser.
     • Shows a banner until the visitor makes a choice, everywhere. We cannot
       geolocate client-side, and a notice is never wrong outside the EEA.
     • Honours Global Privacy Control as an opt-out of ads/personalisation.
     • Exposes window.showConsentPreferences() for the footer link.

   ─────────────────────────────────────────────────────────────────────────
   IMPORTANT — this is NOT an IAB TCF v2.2 certified CMP.
   Google requires a certified CMP to serve ads to EEA/UK users. This banner
   gives you correct Consent Mode signalling and a lawful consent record, but
   before switching AdSense on in Europe, enable Google's own certified CMP
   (AdSense → Privacy & messaging → GDPR message). When you do, set
   window.__ctDisableOwnBanner = true before this script loads so visitors
   don't get two banners; the Consent Mode defaults here stay in force.
   ═══════════════════════════════════════════════════════════════════════════ */
(function () {
  'use strict';

  var STORAGE_KEY = 'ct-consent';
  var SCHEMA_VERSION = 1;
  // GDPR guidance treats consent as going stale; re-ask after 12 months.
  var MAX_AGE_MS = 365 * 24 * 60 * 60 * 1000;

  // EEA + UK + Switzerland. Google matches these against the visitor's IP.
  var CONSENT_REGIONS = [
    'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR',
    'HU', 'IS', 'IE', 'IT', 'LV', 'LI', 'LT', 'LU', 'MT', 'NL', 'NO', 'PL',
    'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB', 'CH'
  ];

  // ── Google Consent Mode v2 ───────────────────────────────────────────────
  window.dataLayer = window.dataLayer || [];
  function gtag() { window.dataLayer.push(arguments); }
  window.gtag = window.gtag || gtag;

  // Strict opt-in for Europe.
  gtag('consent', 'default', {
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    analytics_storage: 'denied',
    functionality_storage: 'granted',
    security_storage: 'granted',
    region: CONSENT_REGIONS,
    wait_for_update: 500
  });

  // Opt-out regimes (US, AU, CA, ...). GPC is applied on top of this below.
  gtag('consent', 'default', {
    ad_storage: 'granted',
    ad_user_data: 'granted',
    ad_personalization: 'granted',
    analytics_storage: 'granted',
    functionality_storage: 'granted',
    security_storage: 'granted'
  });

  // ── Global Privacy Control ───────────────────────────────────────────────
  // A GPC signal is a legally valid opt-out of sale/sharing under CCPA/CPRA
  // and several other US state laws. Applied immediately, before any choice.
  var gpc = navigator.globalPrivacyControl === true;
  if (gpc) {
    gtag('consent', 'update', {
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied'
    });
  }

  // ── Stored preference ────────────────────────────────────────────────────
  function read() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return null;
      var saved = JSON.parse(raw);
      if (!saved || saved.v !== SCHEMA_VERSION) return null;
      if (Date.now() - saved.ts > MAX_AGE_MS) return null;
      return saved;
    } catch (e) {
      // Private mode, disabled storage, or corrupt JSON — treat as no choice.
      return null;
    }
  }

  function write(prefs) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({
        v: SCHEMA_VERSION,
        ts: Date.now(),
        analytics: !!prefs.analytics,
        ads: !!prefs.ads,
        gpc: gpc
      }));
    } catch (e) {
      // Nothing we can do; the banner will simply reappear next visit.
    }
  }

  function apply(prefs) {
    // GPC always wins over an "accept" click — a visitor who opted out at the
    // browser level should not be re-opted-in by a banner they clicked past.
    var ads = prefs.ads && !gpc;
    gtag('consent', 'update', {
      ad_storage: ads ? 'granted' : 'denied',
      ad_user_data: ads ? 'granted' : 'denied',
      ad_personalization: ads ? 'granted' : 'denied',
      analytics_storage: prefs.analytics ? 'granted' : 'denied'
    });
    window.dataLayer.push({ event: 'ct_consent_update', ct_ads: ads, ct_analytics: !!prefs.analytics });
  }

  var stored = read();
  if (stored) apply(stored);

  // ── UI ───────────────────────────────────────────────────────────────────
  if (window.__ctDisableOwnBanner) return;

  var root = null;
  var lastFocus = null;

  function el(tag, cls, html) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (html != null) n.innerHTML = html;
    return n;
  }

  function close() {
    if (root) { root.remove(); root = null; }
    if (lastFocus && lastFocus.focus) { lastFocus.focus(); lastFocus = null; }
    document.removeEventListener('keydown', onKeydown);
  }

  function onKeydown(e) {
    if (e.key !== 'Escape' || !root) return;
    // Esc is only an exit where a choice already exists. With no choice on
    // record, dismissing must not be easier than consenting.
    if (read()) close();
  }

  function decide(prefs) {
    write(prefs);
    apply(prefs);
    close();
  }

  function render(showDetail) {
    close();
    var saved = read() || { analytics: false, ads: false };

    root = el('div', 'ct-consent' + (showDetail ? ' ct-consent--panel' : ''));
    root.setAttribute('role', 'dialog');
    root.setAttribute('aria-modal', showDetail ? 'true' : 'false');
    root.setAttribute('aria-labelledby', 'ct-consent-title');

    var card = el('div', 'ct-consent__card');

    card.appendChild(el('h2', 'ct-consent__title', 'Cookies on CreatorTools'));
    card.appendChild(el('p', 'ct-consent__body',
      'We use cookies that are strictly necessary to run the site and keep it secure. ' +
      'With your permission we also use advertising and measurement cookies, which fund ' +
      'these tools and let us show ads relevant to you. You can change your mind at any ' +
      'time from <strong>Cookie Settings</strong> in the footer. See our ' +
      '<a href="#privacy" data-ct-nav="privacy">Privacy Policy</a>.'));

    if (gpc) {
      card.appendChild(el('p', 'ct-consent__gpc',
        'Your browser is sending a Global Privacy Control signal, so advertising and ' +
        'personalisation cookies stay off regardless of what you choose here.'));
    }

    if (showDetail) {
      var opts = el('div', 'ct-consent__options');
      opts.appendChild(toggleRow('necessary', 'Strictly necessary',
        'Required for the site to work and for reCAPTCHA to block automated abuse. These cannot be switched off.',
        true, true));
      opts.appendChild(toggleRow('analytics', 'Analytics',
        'Aggregate usage measurement, so we can see which tools are worth keeping.',
        saved.analytics, false));
      opts.appendChild(toggleRow('ads', 'Advertising',
        'Used by Google AdSense to serve, cap and measure ads, and to personalise them based on your browsing.',
        saved.ads && !gpc, gpc));
      card.appendChild(opts);
    }

    var actions = el('div', 'ct-consent__actions');

    if (showDetail) {
      actions.appendChild(button('Save preferences', 'ct-btn ct-btn--primary', function () {
        decide({
          analytics: root.querySelector('#ct-opt-analytics').checked,
          ads: root.querySelector('#ct-opt-ads').checked
        });
      }));
      actions.appendChild(button('Reject all', 'ct-btn ct-btn--ghost', function () {
        decide({ analytics: false, ads: false });
      }));
      actions.appendChild(button('Accept all', 'ct-btn ct-btn--ghost', function () {
        decide({ analytics: true, ads: true });
      }));
    } else {
      // Accept and Reject carry equal visual weight — under the GDPR,
      // rejecting must be as easy as accepting.
      actions.appendChild(button('Accept all', 'ct-btn ct-btn--primary', function () {
        decide({ analytics: true, ads: true });
      }));
      actions.appendChild(button('Reject all', 'ct-btn ct-btn--primary ct-btn--secondary', function () {
        decide({ analytics: false, ads: false });
      }));
      actions.appendChild(button('Manage', 'ct-btn ct-btn--ghost', function () {
        render(true);
      }));
    }

    card.appendChild(actions);
    root.appendChild(card);
    document.body.appendChild(root);

    document.addEventListener('keydown', onKeydown);
    var first = root.querySelector('button, input');
    if (first) first.focus();
  }

  function button(label, cls, onClick) {
    var b = el('button', cls, label);
    b.type = 'button';
    b.addEventListener('click', onClick);
    return b;
  }

  function toggleRow(id, title, desc, checked, locked) {
    var row = el('label', 'ct-consent__option');
    row.setAttribute('for', 'ct-opt-' + id);

    var input = document.createElement('input');
    input.type = 'checkbox';
    input.id = 'ct-opt-' + id;
    input.checked = checked;
    input.disabled = !!locked;
    input.className = 'ct-consent__checkbox';

    var textWrap = el('span', 'ct-consent__option-text');
    textWrap.appendChild(el('span', 'ct-consent__option-title', title));
    textWrap.appendChild(el('span', 'ct-consent__option-desc', desc));

    row.appendChild(input);
    row.appendChild(textWrap);
    return row;
  }

  // Footer "Cookie Settings" link calls this.
  window.showConsentPreferences = function () {
    lastFocus = document.activeElement;
    render(true);
  };

  function start() {
    // The Jaspr app owns routing, so it hands us window.ctOpenPrivacy to switch
    // tabs. If the app has not booted yet, fall back to closing the banner so
    // the link is never a dead end.
    document.addEventListener('click', function (e) {
      var nav = e.target.closest && e.target.closest('[data-ct-nav]');
      if (!nav) return;
      e.preventDefault();
      if (typeof window.ctOpenPrivacy === 'function') window.ctOpenPrivacy();
      if (root && read()) close();
      window.scrollTo(0, 0);
    });
    if (!read()) render(false);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();
