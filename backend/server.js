const express = require('express');
const cors = require('cors');

const { init } = require('@heyputer/puter.js/src/init.cjs');

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Puter.js
let puter = null;

async function initializePuter() {
  try {
    console.log('Backend: Initializing Puter.js...');
    // Note: In a production environment, you would use a proper auth token
    // For now, we'll initialize without auth (may have limitations)
    puter = init();
    console.log('Backend: Puter.js initialized successfully');
  } catch (error) {
    console.error('Backend: Error initializing Puter.js:', error);
    console.log('Backend: Falling back to simulation mode');
  }
}

// Puter.js API endpoint (they have a REST API)
const PUTER_API_BASE = 'https://api.puter.com';

// AI Command endpoint
app.post('/api/ai-command', async (req, res) => {
  try {
    const { command } = req.body;

    if (!command) {
      return res.status(400).json({ error: 'Command is required' });
    }

    console.log(`Backend: Processing command: ${command}`);

    if (puter) {
      // Use real Puter.js AI
      const systemPrompt = 'CRITICAL: You are a Flutter UI controller AI. Respond ONLY with valid JSON. No explanations, no HTML, no CSS, no markdown.\n\nFor "make button red" respond exactly: {"commandType": "modifyWidget", "widgetType": "dynamicButton", "property": "backgroundColor", "value": "0xFFFF0000", "targetIndex": 0}\nFor "add button" respond exactly: {"commandType": "addWidget", "widgetType": "dynamicButton", "properties": {"content": "New Button", "backgroundColor": "0xFF2196F3", "textColor": "0xFFFFFFFF", "fontSize": 16}}\nFor "hide progress" respond exactly: {"commandType": "modifyWidget", "widgetType": "progressIndicator", "property": "isVisible", "value": false, "targetIndex": 0}\nFor "show progress" respond exactly: {"commandType": "modifyWidget", "widgetType": "progressIndicator", "property": "isVisible", "value": true, "targetIndex": 0}\nFor "hide profile" respond exactly: {"commandType": "modifyWidget", "widgetType": "profileCard", "property": "isVisible", "value": false, "targetIndex": 0}\n\nUser command: ' + command;

      try {
        const response = await puter.ai.chat(systemPrompt, {
          model: 'gpt-4o',
          temperature: 0.1
        });

        console.log('Backend: Raw Puter.js response:', response);

        // Try to parse as JSON
        let jsonResponse;
        try {
          jsonResponse = typeof response === 'string' ? JSON.parse(response) : response;
          console.log('Backend: Successfully parsed AI response');
        } catch (parseError) {
          console.log('Backend: Response not JSON, returning as message');
          jsonResponse = {
            commandType: 'message',
            message: response,
            rawResponse: true
          };
        }

        res.json(jsonResponse);
      } catch (aiError) {
        console.error('Backend: Puter.js AI error:', aiError);
        console.log('Backend: Falling back to simulation');
        const fallbackResponse = await simulatePuterAI(command, 'System prompt for fallback');
        res.json(fallbackResponse);
      }
    } else {
      // Fallback to simulation
      console.log('Backend: Using simulation mode (Puter.js not available)');
      const response = await simulatePuterAI(command, 'Fallback system prompt');
      res.json(response);
    }

  } catch (error) {
    console.error('Backend: Error processing command:', error);
    res.status(500).json({
      commandType: 'message',
      message: 'Error: ' + error.message,
      error: true
    });
  }
});

// Simulate Puter.js AI responses (for fallback)
// In production, replace with actual Puter.js API calls
async function simulatePuterAI(command, systemPrompt) {
  console.log('Backend: Simulating AI response for:', command);

  // Simple pattern matching for common commands
  const cmd = command.toLowerCase().trim();

  if (cmd.includes('make button red') || cmd.includes('button red')) {
    return {
      commandType: 'modifyWidget',
      widgetType: 'dynamicButton',
      property: 'backgroundColor',
      value: '0xFFFF0000',
      targetIndex: 0
    };
  }

  if (cmd.includes('add button')) {
    return {
      commandType: 'addWidget',
      widgetType: 'dynamicButton',
      properties: {
        content: 'New Button',
        backgroundColor: '0xFF2196F3',
        textColor: '0xFFFFFFFF',
        fontSize: 16
      }
    };
  }

  if (cmd.includes('hide progress')) {
    return {
      commandType: 'modifyWidget',
      widgetType: 'progressIndicator',
      property: 'isVisible',
      value: false,
      targetIndex: 0
    };
  }

  if (cmd.includes('show progress')) {
    return {
      commandType: 'modifyWidget',
      widgetType: 'progressIndicator',
      property: 'isVisible',
      value: true,
      targetIndex: 0
    };
  }

  if (cmd.includes('hide profile')) {
    return {
      commandType: 'modifyWidget',
      widgetType: 'profileCard',
      property: 'isVisible',
      value: false,
      targetIndex: 0
    };
  }

  if (cmd.includes('show profile')) {
    return {
      commandType: 'modifyWidget',
      widgetType: 'profileCard',
      property: 'isVisible',
      value: true,
      targetIndex: 0
    };
  }

  // Default response
  return {
    commandType: 'message',
    message: 'Command processed by AI backend',
    rawResponse: true
  };
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Puter.js Backend Server is running',
    puterAvailable: puter !== null
  });
});

// Start server
app.listen(port, async () => {
  console.log(`Puter.js Backend Server running on port ${port}`);
  await initializePuter();
});
