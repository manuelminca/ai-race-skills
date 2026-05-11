/**
 * whatsapp-manager-hook plugin
 * before_prompt_build hook — injects WhatsApp rules before every WhatsApp message
 * message_sending hook — validates outgoing messages before delivery
 */

import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { definePluginEntry } from 'openclaw/plugin-sdk/plugin-entry';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Load contacts from references/contacts.md
function loadContacts() {
  const contactsPath = resolve(__dirname, '../references/contacts.md');
  try {
    const content = readFileSync(contactsPath, 'utf-8');
    const contacts = {};
    const entries = content.split(/^##\s+/m).filter(e => e.trim());
    for (const entry of entries) {
      const lines = entry.split('\n');
      const name = lines[0].trim();
      let phone = '';
      let type = '';
      let permissions = [];
      for (const line of lines) {
        if (line.includes('**Phone:**')) {
          phone = line.replace(/.*\*\*Phone:\*\*\s*/, '').trim();
        }
        if (line.includes('**Type:**')) {
          type = line.replace(/.*\*\*Type:\*\*\s*/, '').trim();
        }
        if (line.includes('- **')) {
          const perm = line.replace(/^-\s+\*\*|\*\*.*$/g, '').trim();
          if (perm && !perm.includes('Permissions:')) {
            permissions.push(perm);
          }
        }
      }
      if (phone) {
        contacts[phone] = { name, type, permissions };
      }
    }
    return contacts;
  } catch (err) {
    console.warn('[whatsapp-manager-hook] Could not load contacts:', err.message);
    return {};
  }
}

// Load pending replays from references/pending-replays.md
function loadPendingReplays() {
  const replaysPath = resolve(__dirname, '../references/pending-replays.md');
  try {
    const content = readFileSync(replaysPath, 'utf-8');
    // Parse pending replays entries
    const entries = content.split(/^##\s+/m).filter(e => e.trim());
    const replays = [];
    for (const entry of entries) {
      const lines = entry.split('\n');
      const timestamp = lines[0].trim();
      let from = '', to = '', message = '', status = 'pending', attempts = 0;
      for (const line of lines) {
        if (line.includes('**From:**')) from = line.replace(/.*\*\*From:\*\*\s*/, '').trim();
        if (line.includes('**To:**')) to = line.replace(/.*\*\*To:\*\*\s*/, '').trim();
        if (line.includes('**Message:**')) message = line.replace(/.*\*\*Message:\*\*\s*/, '').trim();
        if (line.includes('**Status:**')) status = line.replace(/.*\*\*Status:\*\*\s*/, '').trim();
        if (line.includes('**Attempts:**')) attempts = parseInt(line.replace(/.*\*\*Attempts:\*\*\s*/, '').trim()) || 0;
      }
      if (from && to && message) {
        replays.push({ timestamp, from, to, message, status, attempts });
      }
    }
    return replays;
  } catch (err) {
    console.warn('[whatsapp-manager-hook] Could not load pending replays:', err.message);
    return [];
  }
}

export default definePluginEntry({
  id: 'whatsapp-manager-hook',
  name: 'WhatsApp Manager Hook',
  description: 'Validates and secures WhatsApp message delivery.',
  register(api) {
    // Hook 1: Inject context before processing message
    api.registerHook('agent', 'before_prompt_build', { name: 'whatsappContextInjection' }, async (params) => {
      const inboundMeta = params?.inboundMeta;
      if (inboundMeta?.channel !== 'whatsapp') return;
      const guidePath = resolve(__dirname, '../references/whatsapp-guide.md');
      let guideContent = '';
      try {
        guideContent = readFileSync(guidePath, 'utf-8');
      } catch (err) {
        console.warn('[whatsapp-manager-hook] whatsapp-guide.md not found');
        return;
      }
      return {
        prependContext: `\n=== WHATSAPP OPERATION GUIDE ===\n${guideContent}\n=== END WHATSAPP OPERATION GUIDE ===\n`,
      };
    });

    // Hook 2: CRITICAL — Validate outgoing message before sending
    // Blocks messages to unknown recipients, confirms admin messages
    api.registerHook('agent', 'message_sending', { name: 'whatsappOutboundValidation' }, async (params) => {
      const { target, content, inboundMeta } = params || {};
      
      // Only validate WhatsApp messages
      if (inboundMeta?.channel !== 'whatsapp' && !target?.includes('@c.us')) {
        return; // Not WhatsApp — allow
      }

      console.log('[whatsapp-manager-hook] Validating outbound message:', {
        target,
        contentPreview: content?.substring(0, 80)
      });
      
      const contacts = loadContacts();
      
      // Extract recipient phone from target
      const recipientPhone = target?.replace(/@c.us$/, '').replace(/\D/g, '');
      
      // Check if recipient is in contacts
      const contactEntry = Object.entries(contacts).find(([phone]) => 
        recipientPhone?.includes(phone.replace(/\D/g, ''))
      );

      // If admin (Manuel) — always allow
      if (recipientPhone?.replace(/\D/g, '') === '34679906438') {
        console.log('[whatsapp-manager-hook] Admin message — ALLOWED');
        return;
      }

      // If unknown contact — BLOCK
      if (!contactEntry) {
        console.warn('[whatsapp-manager-hook] UNKNOWN recipient — BLOCKED');
        console.warn('[whatsapp-manager-hook] Message would go to:', target);
        console.warn('[whatsapp-manager-hook] Content preview:', content?.substring(0, 100));
        
        return {
          cancel: true,
          reason: 'OUTBOUND_WHATSAPP_BLOCKED: Unknown recipient. This message has been blocked and flagged for Manuel review.'
        };
      }

      // For known contacts — log but allow
      const [phone, contact] = contactEntry;
      console.log('[whatsapp-manager-hook] Known contact:', contact.name, '- Message ALLOWED');
      
      return { cancel: false };
    });
  },
});