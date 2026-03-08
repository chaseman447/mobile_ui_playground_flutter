// Mobile UI Playground - Drag & Drop Interface
// Flutter Flow-like visual design interface

class AIService {
    constructor() {
        this.apiEndpoint = 'https://openrouter.ai/api/v1/chat/completions';
        this.model = 'mistralai/devstral-small-2505:free';
        this.apiKey = null; // Will be set by user
    }

    setApiKey(key) {
        this.apiKey = key;
        localStorage.setItem('ai_api_key', key);
    }

    getApiKey() {
        if (!this.apiKey) {
            this.apiKey = localStorage.getItem('ai_api_key');
        }
        return this.apiKey;
    }

    async generateStyling(prompt, currentProperties) {
        // Use Puter.js AI instead of OpenRouter
        if (typeof puter === 'undefined' || !puter.ai || !puter.ai.chat) {
            console.log('Puter.js not available, using fallback styling');
            return this.getFallbackStyling(prompt, currentProperties);
        }

        const systemPrompt = `You are a UI styling assistant for a drag-and-drop interface. Given a user request and current component properties, return ONLY a JSON object with the updated CSS properties. Focus on colors, sizes, borders, padding, margins, and visual styling.

Current properties: ${JSON.stringify(currentProperties)}

Supported properties include:
- backgroundColor: hex colors (e.g., "#FF0000")
- color: text color as hex (e.g., "#000000")
- borderRadius: border radius in pixels (e.g., "8px")
- border: border style (e.g., "2px solid #ddd")
- padding: padding in pixels (e.g., "10px")
- margin: margin in pixels (e.g., "5px")
- fontSize: font size (e.g., "16px")
- fontWeight: font weight (e.g., "bold", "normal")
- boxShadow: shadow effects (e.g., "0 2px 4px rgba(0,0,0,0.1)")
- width: element width (e.g., "200px")
- height: element height (e.g., "100px")

Return format: {"backgroundColor": "#color", "color": "#color", "borderRadius": "value", etc.}`;

        try {
            console.log('Using Puter.js AI for styling...');
            
            const response = await puter.ai.chat(prompt, {
                model: 'gpt-4o',
                system: systemPrompt,
                temperature: 0.7
            });
            
            const content = response.toString().trim();
            console.log('Puter.js AI response:', content);
            
            // Parse JSON response
            try {
                return JSON.parse(content);
            } catch (e) {
                // Fallback: extract JSON from response
                const jsonMatch = content.match(/\{[^}]+\}/);
                if (jsonMatch) {
                    return JSON.parse(jsonMatch[0]);
                }
                throw new Error('Invalid AI response format');
            }
        } catch (error) {
            console.error('Puter.js AI styling error:', error);
            // Return fallback styling on error
            return this.getFallbackStyling(prompt, currentProperties);
        }
    }

    getFallbackStyling(prompt, currentProperties) {
        // Simple fallback styling based on common keywords
        const styling = {};
        const lowerPrompt = prompt.toLowerCase();
        
        // Color keywords
        if (lowerPrompt.includes('blue')) styling.backgroundColor = '#007bff';
        else if (lowerPrompt.includes('red')) styling.backgroundColor = '#dc3545';
        else if (lowerPrompt.includes('green')) styling.backgroundColor = '#28a745';
        else if (lowerPrompt.includes('yellow')) styling.backgroundColor = '#ffc107';
        else if (lowerPrompt.includes('purple')) styling.backgroundColor = '#6f42c1';
        else if (lowerPrompt.includes('orange')) styling.backgroundColor = '#fd7e14';
        else if (lowerPrompt.includes('dark')) styling.backgroundColor = '#343a40';
        
        // Style keywords
        if (lowerPrompt.includes('rounded') || lowerPrompt.includes('round')) {
            styling.borderRadius = '8px';
        }
        if (lowerPrompt.includes('border')) {
            styling.border = '2px solid #ddd';
        }
        if (lowerPrompt.includes('shadow')) {
            styling.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';
        }
        
        return Object.keys(styling).length > 0 ? styling : { backgroundColor: '#f8f9fa' };
    }

    async suggestColorPalette(theme = 'modern') {
        if (!this.getApiKey()) {
            return this.getFallbackPalette(theme);
        }

        const prompt = `Generate a ${theme} color palette for UI components. Create a cohesive and visually appealing palette suitable for modern web interfaces. Return ONLY a JSON object with: {"primary": "#color", "secondary": "#color", "accent": "#color", "background": "#color", "text": "#color"}`;

        try {
            const response = await fetch(this.apiEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.getApiKey()}`
                },
                body: JSON.stringify({
                    model: this.model,
                    messages: [{ role: 'user', content: prompt }],
                    max_tokens: 100,
                    temperature: 0.8
                })
            });

            if (!response.ok) {
                throw new Error(`API error: ${response.status}`);
            }

            const data = await response.json();
            const content = data.choices[0].message.content.trim();
            
            const jsonMatch = content.match(/\{[^}]+\}/);
            if (jsonMatch) {
                return JSON.parse(jsonMatch[0]);
            }
            throw new Error('Invalid color palette response');
        } catch (error) {
            console.error('AI color palette error:', error);
            return this.getFallbackPalette(theme);
        }
    }

    async generateStructuredOutput(userCommand) {
        if (!this.getApiKey()) {
            return this.getFallbackStructuredOutput(userCommand);
        }

        const systemInstruction = `You are a UI modification assistant for a drag-and-drop web interface. Your task is to interpret user commands and generate a JSON object that describes UI changes or actions.

For UI changes, the JSON should have "component", "property", "value", and optionally "operation".
For component management, use "commandType" with relevant fields.

Supported components:
- button: backgroundColor, color, borderRadius, padding, margin, fontSize, fontWeight, width, height, border, boxShadow
- text: color, fontSize, fontWeight, textAlign, padding, margin
- input: backgroundColor, color, borderRadius, border, padding, fontSize
- container: backgroundColor, borderRadius, border, padding, margin, width, height
- image: width, height, borderRadius, border

Supported operations: "add", "subtract", "multiply", "divide"

Examples:
- "make the button blue": {"component": "button", "property": "backgroundColor", "value": "#0000FF"}
- "increase font size by 2px": {"component": "text", "property": "fontSize", "operation": "add", "value": "2px"}
- "add rounded corners": {"component": "button", "property": "borderRadius", "value": "8px"}

Return ONLY valid JSON. If command is unclear, return: {}.

JSON Output:`;

        try {
            const response = await fetch(this.apiEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.getApiKey()}`
                },
                body: JSON.stringify({
                    model: this.model,
                    messages: [
                        { role: 'system', content: systemInstruction },
                        { role: 'user', content: userCommand }
                    ],
                    max_tokens: 300,
                    temperature: 0.7,
                    response_format: { type: 'json_object' }
                })
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(`AI API error (${response.status}): ${errorData.error?.message || 'Unknown error'}`);
            }

            const data = await response.json();
            const content = data.choices[0].message.content.trim();
            
            try {
                return JSON.parse(content);
            } catch (e) {
                console.error('Error parsing structured output:', e);
                return this.getFallbackStructuredOutput(userCommand);
            }
        } catch (error) {
            console.error('AI structured output error:', error);
            return this.getFallbackStructuredOutput(userCommand);
        }
    }

    getFallbackStructuredOutput(userCommand) {
        const lowerCommand = userCommand.toLowerCase();
        
        // Simple pattern matching for common commands
        if (lowerCommand.includes('blue')) {
            return { component: 'button', property: 'backgroundColor', value: '#007bff' };
        }
        if (lowerCommand.includes('red')) {
            return { component: 'button', property: 'backgroundColor', value: '#dc3545' };
        }
        if (lowerCommand.includes('green')) {
            return { component: 'button', property: 'backgroundColor', value: '#28a745' };
        }
        if (lowerCommand.includes('rounded') || lowerCommand.includes('round')) {
            return { component: 'button', property: 'borderRadius', value: '8px' };
        }
        if (lowerCommand.includes('bigger') || lowerCommand.includes('larger')) {
            return { component: 'text', property: 'fontSize', operation: 'add', value: '2px' };
        }
        if (lowerCommand.includes('smaller')) {
            return { component: 'text', property: 'fontSize', operation: 'subtract', value: '2px' };
        }
        
        return {};
    }

    getFallbackPalette(theme) {
        const palettes = {
            modern: {
                primary: '#007bff',
                secondary: '#6c757d',
                accent: '#17a2b8',
                background: '#ffffff',
                text: '#212529'
            },
            dark: {
                primary: '#375a7f',
                secondary: '#444',
                accent: '#e74c3c',
                background: '#222',
                text: '#ffffff'
            },
            pastel: {
                primary: '#ffb3ba',
                secondary: '#bae1ff',
                accent: '#ffffba',
                background: '#f8f9fa',
                text: '#495057'
            },
            vibrant: {
                primary: '#ff6b6b',
                secondary: '#4ecdc4',
                accent: '#45b7d1',
                background: '#ffffff',
                text: '#2c3e50'
            },
            minimal: {
                primary: '#333333',
                secondary: '#666666',
                accent: '#999999',
                background: '#ffffff',
                text: '#000000'
            }
        };
        
        return palettes[theme] || palettes.modern;
    }
}

class DragDropDesigner {
    constructor() {
        this.components = new Map();
        this.selectedComponent = null;
        this.draggedElement = null;
        this.componentCounter = 0;
        this.undoStack = [];
        this.redoStack = [];
        this.maxUndoSteps = 50;
        this.savedLayouts = new Map();
        this.aiService = new AIService();
        
        this.init();
    }

    init() {
        this.bindEvents();
        this.setupCanvas();
        this.loadFromStorage();
        this.loadSavedLayouts();
        this.setupAIControls();
        this.setupLayoutManager();
    }

    bindEvents() {
        // Palette drag events
        const paletteItems = document.querySelectorAll('.palette-item');
        paletteItems.forEach(item => {
            item.addEventListener('dragstart', this.handlePaletteDragStart.bind(this));
            item.addEventListener('dragend', this.handlePaletteDragEnd.bind(this));
            
            // Touch events for mobile
            item.addEventListener('touchstart', this.handlePaletteTouchStart.bind(this), { passive: false });
            item.addEventListener('touchmove', this.handlePaletteTouchMove.bind(this), { passive: false });
            item.addEventListener('touchend', this.handlePaletteTouchEnd.bind(this), { passive: false });
        });

        // Canvas drop events
        const canvas = document.getElementById('designCanvas');
        canvas.addEventListener('dragover', this.handleCanvasDragOver.bind(this));
        canvas.addEventListener('drop', this.handleCanvasDrop.bind(this));
        canvas.addEventListener('dragleave', this.handleCanvasDragLeave.bind(this));
        canvas.addEventListener('click', this.handleCanvasClick.bind(this));
        
        // Touch events for canvas
        canvas.addEventListener('touchstart', this.handleCanvasTouchStart.bind(this), { passive: false });
        canvas.addEventListener('touchmove', this.handleCanvasTouchMove.bind(this), { passive: false });
        canvas.addEventListener('touchend', this.handleCanvasTouchEnd.bind(this), { passive: false });

        // Toolbar events
        document.getElementById('canvasResetBtn').addEventListener('click', this.clearCanvas.bind(this));
        document.getElementById('canvasUndoBtn').addEventListener('click', this.undo.bind(this));
        document.getElementById('canvasRedoBtn').addEventListener('click', this.redo.bind(this));

        // Keyboard shortcuts
        document.addEventListener('keydown', this.handleKeydown.bind(this));

        // Window resize
        window.addEventListener('resize', this.handleResize.bind(this));
        
        // Initialize touch state
        this.touchState = {
            isDragging: false,
            dragElement: null,
            startX: 0,
            startY: 0,
            offsetX: 0,
            offsetY: 0,
            componentType: null
        };
    }

    setupCanvas() {
        const canvas = document.getElementById('designCanvas');
        // Clear existing content and add drop zone
        canvas.innerHTML = '<div class="drop-zone"></div>';
        canvas.classList.add('design-canvas');
    }

    handlePaletteDragStart(e) {
        const paletteItem = e.target.closest('.palette-item');
        if (!paletteItem) return;
        
        const componentType = paletteItem.dataset.component;
        e.dataTransfer.setData('text/plain', componentType);
        e.dataTransfer.effectAllowed = 'copy';
        
        // Add dragging class to original item
        paletteItem.classList.add('dragging');
        
        // Create enhanced ghost element
        const ghost = this.createDragGhost(paletteItem, componentType);
        document.body.appendChild(ghost);
        e.dataTransfer.setDragImage(ghost, 30, 30);
        
        // Add visual feedback to canvas
        const canvas = document.getElementById('designCanvas');
        canvas.classList.add('drag-active');
        
        // Store drag data
        this.dragData = {
            type: componentType,
            ghost: ghost,
            originalItem: paletteItem
        };
        
        setTimeout(() => document.body.removeChild(ghost), 0);
    }

    handlePaletteDragEnd(e) {
        // Clean up any ghost elements
        const ghosts = document.querySelectorAll('.drag-ghost');
        ghosts.forEach(ghost => ghost.remove());
        
        // Remove dragging state from palette items
        const paletteItems = document.querySelectorAll('.palette-item.dragging');
        paletteItems.forEach(item => item.classList.remove('dragging'));
        
        // Remove canvas drag state
        const canvas = document.getElementById('designCanvas');
        canvas.classList.remove('drag-active');
        
        // Clear drag data
        this.dragData = null;
    }

    createGhostElement(componentType) {
        const ghost = document.createElement('div');
        ghost.className = 'drag-ghost';
        ghost.style.padding = '10px';
        ghost.style.background = 'rgba(255, 255, 255, 0.9)';
        ghost.style.border = '2px solid #007bff';
        ghost.style.borderRadius = '6px';
        ghost.textContent = componentType.charAt(0).toUpperCase() + componentType.slice(1);
        return ghost;
    }
    
    createDragGhost(originalItem, componentType) {
        const ghost = document.createElement('div');
        ghost.className = 'drag-ghost';
        ghost.style.cssText = `
            position: fixed;
            top: -1000px;
            left: -1000px;
            width: 80px;
            height: 50px;
            background: linear-gradient(135deg, #007AFF, #00D4FF);
            border: 2px dashed rgba(255, 255, 255, 0.8);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 12px;
            font-weight: 600;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
            box-shadow: 0 8px 25px rgba(0, 122, 255, 0.4);
            z-index: 10000;
            pointer-events: none;
            transform: rotate(-2deg);
        `;
        
        // Add component type text
        const typeMap = {
            'button': '🔘 Button',
            'text': '📝 Text',
            'textfield': '📝 Input',
            'image': '🖼️ Image',
            'container': '📦 Container',
            'switch': '🔘 Switch',
            'slider': '🎚️ Slider'
        };
        
        ghost.textContent = typeMap[componentType] || componentType;
        return ghost;
    }

    handleCanvasDragOver(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'copy';
        
        const canvas = e.currentTarget;
        canvas.classList.add('drag-over');
    }

    handleCanvasDragLeave(e) {
        const canvas = e.currentTarget;
        if (!canvas.contains(e.relatedTarget)) {
            canvas.classList.remove('drag-over');
        }
    }

    handleCanvasDrop(e) {
        e.preventDefault();
        const canvas = e.currentTarget;
        canvas.classList.remove('drag-over');
        
        const componentType = e.dataTransfer.getData('text/plain');
        if (!componentType) return;
        
        const rect = canvas.getBoundingClientRect();
        const x = e.clientX - rect.left - 20; // Offset for padding
        const y = e.clientY - rect.top - 20;
        
        this.createComponent(componentType, x, y);
    }

    createComponent(type, x, y, properties = {}) {
        this.saveState(); // Save for undo
        
        const id = `component_${++this.componentCounter}`;
        const component = {
            id,
            type,
            x: Math.max(0, x),
            y: Math.max(0, y),
            width: this.getDefaultWidth(type),
            height: this.getDefaultHeight(type),
            properties: { ...this.getDefaultProperties(type), ...properties }
        };
        
        this.components.set(id, component);
        this.renderComponent(component);
        this.selectComponent(id);
        this.saveToStorage();
        
        return component;
    }

    getDefaultWidth(type) {
        const widths = {
            button: 100,
            text: 100,
            image: 100,
            container: 150,
            textfield: 200,
            switch: 60,
            slider: 200
        };
        return widths[type] || 100;
    }

    getDefaultHeight(type) {
        const heights = {
            button: 40,
            text: 30,
            image: 100,
            container: 100,
            textfield: 40,
            switch: 30,
            slider: 30
        };
        return heights[type] || 40;
    }

    getDefaultProperties(type) {
        const defaults = {
            button: {
                text: 'Button',
                backgroundColor: '#007bff',
                textColor: '#ffffff',
                fontSize: 14,
                borderRadius: 6
            },
            text: {
                text: 'Text Label',
                fontSize: 16,
                textColor: '#333333',
                fontWeight: 'normal',
                textAlign: 'left'
            },
            image: {
                src: 'https://picsum.photos/100/100?random=' + Math.floor(Math.random() * 1000),
                alt: 'Image',
                borderRadius: 4
            },
            container: {
                backgroundColor: 'rgba(255, 255, 255, 0.5)',
                borderColor: '#cccccc',
                borderWidth: 2,
                borderRadius: 8,
                borderStyle: 'dashed'
            },
            textfield: {
                placeholder: 'Enter text...',
                value: '',
                fontSize: 14,
                borderColor: '#dddddd',
                borderRadius: 4
            },
            switch: {
                checked: false,
                activeColor: '#007bff',
                inactiveColor: '#cccccc'
            },
            slider: {
                value: 50,
                min: 0,
                max: 100,
                step: 1,
                trackColor: '#dddddd',
                thumbColor: '#007bff'
            }
        };
        return defaults[type] || {};
    }

    renderComponent(component) {
        const canvas = document.getElementById('designCanvas');
        const element = document.createElement('div');
        element.className = 'draggable-component';
        element.id = component.id;
        element.style.left = component.x + 'px';
        element.style.top = component.y + 'px';
        element.style.width = component.width + 'px';
        element.style.height = component.height + 'px';
        
        // Create component content
        const content = this.createComponentContent(component);
        element.appendChild(content);
        
        // Add resize handles
        this.addResizeHandles(element);
        
        // Add event listeners
        element.addEventListener('mousedown', this.handleComponentMouseDown.bind(this));
        element.addEventListener('click', this.handleComponentClick.bind(this));
        
        canvas.appendChild(element);
    }

    createComponentContent(component) {
        const { type, properties } = component;
        let content;
        
        switch (type) {
            case 'button':
                content = document.createElement('button');
                content.className = 'component-button';
                content.textContent = properties.text;
                content.style.backgroundColor = properties.backgroundColor;
                content.style.color = properties.textColor;
                content.style.fontSize = properties.fontSize + 'px';
                content.style.borderRadius = properties.borderRadius + 'px';
                content.style.border = 'none';
                content.style.cursor = 'pointer';
                break;
                
            case 'text':
                content = document.createElement('div');
                content.className = 'component-text';
                content.textContent = properties.text;
                content.style.fontSize = properties.fontSize + 'px';
                content.style.color = properties.textColor;
                content.style.fontWeight = properties.fontWeight;
                content.style.textAlign = properties.textAlign;
                content.style.display = 'flex';
                content.style.alignItems = 'center';
                break;
                
            case 'image':
                content = document.createElement('div');
                content.className = 'component-image';
                content.style.borderRadius = properties.borderRadius + 'px';
                const img = document.createElement('img');
                img.src = properties.src;
                img.alt = properties.alt;
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'cover';
                img.style.borderRadius = 'inherit';
                content.appendChild(img);
                break;
                
            case 'container':
                content = document.createElement('div');
                content.className = 'component-container';
                content.style.backgroundColor = properties.backgroundColor;
                content.style.borderColor = properties.borderColor;
                content.style.borderWidth = properties.borderWidth + 'px';
                content.style.borderRadius = properties.borderRadius + 'px';
                content.style.borderStyle = properties.borderStyle;
                content.style.display = 'flex';
                content.style.alignItems = 'center';
                content.style.justifyContent = 'center';
                content.textContent = 'Container';
                break;
                
            case 'textfield':
                content = document.createElement('input');
                content.className = 'component-textfield';
                content.type = 'text';
                content.placeholder = properties.placeholder;
                content.value = properties.value;
                content.style.fontSize = properties.fontSize + 'px';
                content.style.borderColor = properties.borderColor;
                content.style.borderRadius = properties.borderRadius + 'px';
                content.style.border = '1px solid ' + properties.borderColor;
                content.style.padding = '8px';
                content.style.boxSizing = 'border-box';
                break;
                
            case 'switch':
                content = document.createElement('div');
                content.className = 'component-switch';
                if (properties.checked) content.classList.add('active');
                content.style.backgroundColor = properties.checked ? properties.activeColor : properties.inactiveColor;
                content.style.borderRadius = '15px';
                content.style.position = 'relative';
                content.style.cursor = 'pointer';
                content.addEventListener('click', () => {
                    properties.checked = !properties.checked;
                    content.classList.toggle('active', properties.checked);
                    content.style.backgroundColor = properties.checked ? properties.activeColor : properties.inactiveColor;
                    this.updatePropertiesPanel();
                });
                break;
                
            case 'slider':
                content = document.createElement('div');
                content.className = 'component-slider';
                content.style.backgroundColor = properties.trackColor;
                content.style.borderRadius = '10px';
                content.style.position = 'relative';
                const thumb = document.createElement('div');
                thumb.className = 'slider-thumb';
                thumb.style.backgroundColor = properties.thumbColor;
                thumb.style.position = 'absolute';
                thumb.style.width = '20px';
                thumb.style.height = '20px';
                thumb.style.borderRadius = '50%';
                thumb.style.top = '50%';
                thumb.style.transform = 'translateY(-50%)';
                thumb.style.left = ((properties.value - properties.min) / (properties.max - properties.min)) * 100 + '%';
                content.appendChild(thumb);
                break;
                
            default:
                content = document.createElement('div');
                content.textContent = type;
        }
        
        content.style.width = '100%';
        content.style.height = '100%';
        content.style.pointerEvents = 'none'; // Prevent interference with dragging
        
        return content;
    }

    addResizeHandles(element) {
        // Remove existing handles
        const existingHandles = element.querySelectorAll('.resize-handle');
        existingHandles.forEach(handle => handle.remove());
        
        // Add new handles for all corners and edges
        const positions = [
            { pos: 'nw', cursor: 'nw-resize' },
            { pos: 'n', cursor: 'n-resize' },
            { pos: 'ne', cursor: 'ne-resize' },
            { pos: 'e', cursor: 'e-resize' },
            { pos: 'se', cursor: 'se-resize' },
            { pos: 's', cursor: 's-resize' },
            { pos: 'sw', cursor: 'sw-resize' },
            { pos: 'w', cursor: 'w-resize' }
        ];
        
        positions.forEach(({ pos, cursor }) => {
            const handle = document.createElement('div');
            handle.className = `resize-handle resize-${pos}`;
            handle.style.cursor = cursor;
            handle.addEventListener('mousedown', (e) => this.handleResizeStart(pos, e));
            element.appendChild(handle);
        });
        
        // Add delete button
        const deleteBtn = document.createElement('div');
        deleteBtn.className = 'component-delete-btn';
        deleteBtn.innerHTML = '×';
        deleteBtn.title = 'Delete component';
        deleteBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            this.deleteComponent();
        });
        element.appendChild(deleteBtn);
    }

    handleComponentMouseDown(e) {
        if (e.target.classList.contains('resize-handle') || e.target.classList.contains('component-delete-btn')) return;
        
        e.preventDefault();
        const component = e.currentTarget;
        const componentId = component.id;
        
        this.selectComponent(componentId);
        this.saveState(); // Save state for undo
        
        const canvas = document.getElementById('designCanvas');
        const canvasRect = canvas.getBoundingClientRect();
        
        const startX = e.clientX;
        const startY = e.clientY;
        const startLeft = parseInt(component.style.left);
        const startTop = parseInt(component.style.top);
        
        // Add dragging class for visual feedback
        component.classList.add('dragging');
        
        const handleMouseMove = (e) => {
            const deltaX = e.clientX - startX;
            const deltaY = e.clientY - startY;
            
            const componentWidth = parseInt(component.style.width);
            const componentHeight = parseInt(component.style.height);
            
            // Calculate boundaries
            const maxLeft = canvasRect.width - componentWidth - 20; // Account for padding
            const maxTop = canvasRect.height - componentHeight - 20;
            
            const newLeft = Math.max(0, Math.min(maxLeft, startLeft + deltaX));
            const newTop = Math.max(0, Math.min(maxTop, startTop + deltaY));
            
            component.style.left = newLeft + 'px';
            component.style.top = newTop + 'px';
            
            // Update component data
            const componentData = this.components.get(componentId);
            if (componentData) {
                componentData.x = newLeft;
                componentData.y = newTop;
            }
        };
        
        const handleMouseUp = () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
            component.classList.remove('dragging');
            this.updatePropertiesPanel();
            this.saveToStorage();
        };
        
        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
    }

    handleComponentClick(e) {
        e.stopPropagation();
        const componentId = e.currentTarget.id;
        this.selectComponent(componentId);
    }

    clearSelection() {
        // Remove selection from all components
        document.querySelectorAll('.draggable-component.selected').forEach(el => {
            el.classList.remove('selected');
            this.removeResizeHandles(el);
        });
        
        this.selectedComponent = null;
        
        // Clear properties panel
        this.showNoSelectionMessage();
    }

    removeResizeHandles(element) {
        const handles = element.querySelectorAll('.resize-handle');
        handles.forEach(handle => handle.remove());
    }

    enableComponentDragging(component) {
        // Component dragging is already handled in handleComponentMouseDown
        // This method can be used for additional drag enhancements if needed
    }

    handleCanvasClick(e) {
        if (e.target.id === 'designCanvas' || e.target.classList.contains('drop-zone')) {
            this.deselectAll();
        }
    }

    selectComponent(componentId) {
        this.deselectAll();
        
        const element = document.getElementById(componentId);
        if (element) {
            element.classList.add('selected');
            this.selectedComponent = componentId;
            
            // Ensure resize handles are present
            if (!element.querySelector('.resize-handle')) {
                this.addResizeHandles(element);
            }
            
            this.updatePropertiesPanel();
        }
    }

    deselectAll() {
        const selected = document.querySelectorAll('.draggable-component.selected');
        selected.forEach(el => {
            el.classList.remove('selected');
            // Keep resize handles as they're added during component creation
        });
        this.selectedComponent = null;
        this.showNoSelectionMessage();
    }

    updatePropertiesPanel() {
        const panel = document.getElementById('propertiesContent');
        if (!this.selectedComponent) {
            this.showNoSelectionMessage();
            return;
        }
        
        const component = this.components.get(this.selectedComponent);
        if (!component) return;
        
        panel.innerHTML = this.generatePropertiesHTML(component);
        this.bindPropertyEvents();
        
        // Add AI controls after updating properties
        this.setupAIControls();
    }

    showNoSelectionMessage() {
        const panel = document.getElementById('propertiesContent');
        panel.innerHTML = '<div class="no-selection"><p>Select a component to edit its properties</p></div>';
        
        // Remove AI controls when no component is selected
        const existingControls = document.querySelector('.ai-controls');
        if (existingControls) {
            existingControls.remove();
        }
    }

    showComponentProperties(component) {
        const panel = document.querySelector('.properties-panel');
        const content = panel.querySelector('.properties-content');
        
        let propertiesHTML = `
            <div class="property-group">
                <h4>${component.type.charAt(0).toUpperCase() + component.type.slice(1)} Properties</h4>
        `;
        
        // Common properties for all components
        propertiesHTML += `
            <div class="property-field">
                <label>Width (px):</label>
                <input type="number" value="${component.width || 100}" min="10" max="400" 
                       onchange="designer.updateComponentProperty('${component.id}', 'width', this.value)">
            </div>
            <div class="property-field">
                <label>Height (px):</label>
                <input type="number" value="${component.height || 40}" min="10" max="200" 
                       onchange="designer.updateComponentProperty('${component.id}', 'height', this.value)">
            </div>
            <div class="property-field">
                <label>Background Color:</label>
                <input type="color" value="${component.backgroundColor || '#ffffff'}" 
                       onchange="designer.updateComponentProperty('${component.id}', 'backgroundColor', this.value)">
            </div>
        `;
        
        // Type-specific properties
        switch(component.type) {
            case 'button':
                propertiesHTML += `
                    <div class="property-field">
                        <label>Button Text:</label>
                        <input type="text" value="${component.text || 'Button'}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'text', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Button Color:</label>
                        <input type="color" value="${component.buttonColor || '#007AFF'}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'buttonColor', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Text Color:</label>
                        <input type="color" value="${component.textColor || '#ffffff'}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'textColor', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Border Radius:</label>
                        <input type="range" min="0" max="25" value="${component.borderRadius || 8}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'borderRadius', this.value)">
                        <span>${component.borderRadius || 8}px</span>
                    </div>
                `;
                break;
            case 'text':
                propertiesHTML += `
                    <div class="property-field">
                        <label>Text Content:</label>
                        <textarea rows="3" onchange="designer.updateComponentProperty('${component.id}', 'text', this.value)">${component.text || 'Text'}</textarea>
                    </div>
                    <div class="property-field">
                        <label>Font Size:</label>
                        <input type="range" min="10" max="32" value="${component.fontSize || 16}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'fontSize', this.value)">
                        <span>${component.fontSize || 16}px</span>
                    </div>
                    <div class="property-field">
                        <label>Text Color:</label>
                        <input type="color" value="${component.textColor || '#000000'}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'textColor', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Text Align:</label>
                        <select onchange="designer.updateComponentProperty('${component.id}', 'textAlign', this.value)">
                            <option value="left" ${component.textAlign === 'left' ? 'selected' : ''}>Left</option>
                            <option value="center" ${component.textAlign === 'center' ? 'selected' : ''}>Center</option>
                            <option value="right" ${component.textAlign === 'right' ? 'selected' : ''}>Right</option>
                        </select>
                    </div>
                `;
                break;
            case 'textfield':
                propertiesHTML += `
                    <div class="property-field">
                        <label>Placeholder:</label>
                        <input type="text" value="${component.placeholder || 'Enter text...'}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'placeholder', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Input Type:</label>
                        <select onchange="designer.updateComponentProperty('${component.id}', 'inputType', this.value)">
                            <option value="text" ${component.inputType === 'text' ? 'selected' : ''}>Text</option>
                            <option value="email" ${component.inputType === 'email' ? 'selected' : ''}>Email</option>
                            <option value="password" ${component.inputType === 'password' ? 'selected' : ''}>Password</option>
                            <option value="number" ${component.inputType === 'number' ? 'selected' : ''}>Number</option>
                        </select>
                    </div>
                    <div class="property-field">
                        <label>Border Color:</label>
                        <input type="color" value="${component.borderColor || '#cccccc'}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'borderColor', this.value)">
                    </div>
                `;
                break;
            case 'image':
                propertiesHTML += `
                    <div class="property-field">
                        <label>Image URL:</label>
                        <input type="url" value="${component.src || ''}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'src', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Alt Text:</label>
                        <input type="text" value="${component.alt || ''}" 
                               onchange="designer.updateComponentProperty('${component.id}', 'alt', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Object Fit:</label>
                        <select onchange="designer.updateComponentProperty('${component.id}', 'objectFit', this.value)">
                            <option value="cover" ${component.objectFit === 'cover' ? 'selected' : ''}>Cover</option>
                            <option value="contain" ${component.objectFit === 'contain' ? 'selected' : ''}>Contain</option>
                            <option value="fill" ${component.objectFit === 'fill' ? 'selected' : ''}>Fill</option>
                        </select>
                    </div>
                `;
                break;
        }
        
        propertiesHTML += `
                <button class="delete-btn" onclick="designer.deleteComponent('${component.id}')">Delete Component</button>
            </div>
        `;
        
        content.innerHTML = propertiesHTML;
    }

    updateComponentProperty(componentId, property, value) {
        const component = this.components.get(componentId);
        if (!component) return;
        
        // Convert numeric values
        if (['width', 'height', 'fontSize', 'borderRadius'].includes(property)) {
            value = parseInt(value) || 0;
        }
        
        // Update component data
        if (['width', 'height'].includes(property)) {
            component[property] = value;
        } else {
            component.properties = component.properties || {};
            component.properties[property] = value;
        }
        
        // Update visual element
        this.updateComponentElement(component);
        this.saveToStorage();
        
        // Refresh properties panel to show updated values
        if (this.selectedComponent === componentId) {
            this.updatePropertiesPanel();
        }
    }

    generatePropertiesHTML(component) {
        const { type, properties, x, y, width, height } = component;
        
        let html = `
            <div class="property-group">
                <h4>Position & Size</h4>
                <div class="property-field">
                    <label>X Position</label>
                    <input type="number" id="prop-x" value="${x}" min="0">
                </div>
                <div class="property-field">
                    <label>Y Position</label>
                    <input type="number" id="prop-y" value="${y}" min="0">
                </div>
                <div class="property-field">
                    <label>Width</label>
                    <input type="number" id="prop-width" value="${width}" min="10">
                </div>
                <div class="property-field">
                    <label>Height</label>
                    <input type="number" id="prop-height" value="${height}" min="10">
                </div>
            </div>
        `;
        
        // Type-specific properties
        html += '<div class="property-group"><h4>Properties</h4>';
        
        switch (type) {
            case 'button':
                html += `
                    <div class="property-field">
                        <label>Text</label>
                        <input type="text" id="prop-text" value="${properties.text}">
                    </div>
                    <div class="property-field">
                        <label>Background Color</label>
                        <div class="color-picker-wrapper">
                            <input type="color" id="prop-backgroundColor" value="${properties.backgroundColor}" class="color-picker">
                            <input type="text" value="${properties.backgroundColor}">
                        </div>
                    </div>
                    <div class="property-field">
                        <label>Text Color</label>
                        <div class="color-picker-wrapper">
                            <input type="color" id="prop-textColor" value="${properties.textColor}" class="color-picker">
                            <input type="text" value="${properties.textColor}">
                        </div>
                    </div>
                    <div class="property-field">
                        <label>Font Size</label>
                        <input type="number" id="prop-fontSize" value="${properties.fontSize}" min="8" max="72">
                    </div>
                    <div class="property-field">
                        <label>Border Radius</label>
                        <input type="number" id="prop-borderRadius" value="${properties.borderRadius}" min="0">
                    </div>
                `;
                break;
                
            case 'text':
                html += `
                    <div class="property-field">
                        <label>Text</label>
                        <textarea id="prop-text">${properties.text}</textarea>
                    </div>
                    <div class="property-field">
                        <label>Font Size</label>
                        <input type="number" id="prop-fontSize" value="${properties.fontSize}" min="8" max="72">
                    </div>
                    <div class="property-field">
                        <label>Text Color</label>
                        <div class="color-picker-wrapper">
                            <input type="color" id="prop-textColor" value="${properties.textColor}" class="color-picker">
                            <input type="text" value="${properties.textColor}">
                        </div>
                    </div>
                    <div class="property-field">
                        <label>Font Weight</label>
                        <select id="prop-fontWeight">
                            <option value="normal" ${properties.fontWeight === 'normal' ? 'selected' : ''}>Normal</option>
                            <option value="bold" ${properties.fontWeight === 'bold' ? 'selected' : ''}>Bold</option>
                        </select>
                    </div>
                    <div class="property-field">
                        <label>Text Align</label>
                        <select id="prop-textAlign">
                            <option value="left" ${properties.textAlign === 'left' ? 'selected' : ''}>Left</option>
                            <option value="center" ${properties.textAlign === 'center' ? 'selected' : ''}>Center</option>
                            <option value="right" ${properties.textAlign === 'right' ? 'selected' : ''}>Right</option>
                        </select>
                    </div>
                `;
                break;
                
            case 'image':
                html += `
                    <div class="property-field">
                        <label>Image URL</label>
                        <input type="url" id="prop-src" value="${properties.src}">
                    </div>
                    <div class="property-field">
                        <label>Alt Text</label>
                        <input type="text" id="prop-alt" value="${properties.alt}">
                    </div>
                    <div class="property-field">
                        <label>Border Radius</label>
                        <input type="number" id="prop-borderRadius" value="${properties.borderRadius}" min="0">
                    </div>
                `;
                break;
        }
        
        html += '</div>';
        html += '<button class="delete-component-btn" onclick="designer.deleteComponent()">Delete Component</button>';
        
        return html;
    }

    bindPropertyEvents() {
        const inputs = document.querySelectorAll('#propertiesContent input, #propertiesContent select, #propertiesContent textarea');
        inputs.forEach(input => {
            input.addEventListener('input', this.handlePropertyChange.bind(this));
            input.addEventListener('change', this.handlePropertyChange.bind(this));
        });
    }

    handlePropertyChange(e) {
        if (!this.selectedComponent) return;
        
        const component = this.components.get(this.selectedComponent);
        if (!component) return;
        
        const property = e.target.id.replace('prop-', '');
        let value = e.target.value;
        
        // Convert numeric values
        if (['x', 'y', 'width', 'height', 'fontSize', 'borderRadius'].includes(property)) {
            value = parseInt(value) || 0;
        }
        
        // Update component data
        if (['x', 'y', 'width', 'height'].includes(property)) {
            component[property] = value;
        } else {
            component.properties[property] = value;
        }
        
        // Update visual element
        this.updateComponentElement(component);
        this.saveToStorage();
    }

    updateComponentElement(component) {
        const element = document.getElementById(component.id);
        if (!element) return;
        
        const props = component.properties || {};
        
        // Update position and size
        element.style.left = component.x + 'px';
        element.style.top = component.y + 'px';
        element.style.width = component.width + 'px';
        element.style.height = component.height + 'px';
        
        // Update content
        const content = element.querySelector(':not(.resize-handle)');
        if (content) {
            element.removeChild(content);
        }
        
        const newContent = this.createComponentContent(component);
        element.insertBefore(newContent, element.firstChild);
        
        // Apply additional styling based on component type
        switch(component.type) {
            case 'button':
                if (props.backgroundColor) newContent.style.backgroundColor = props.backgroundColor;
                if (props.textColor) newContent.style.color = props.textColor;
                if (props.borderRadius !== undefined) newContent.style.borderRadius = props.borderRadius + 'px';
                break;
                
            case 'text':
                if (props.fontSize) newContent.style.fontSize = props.fontSize + 'px';
                if (props.textColor) newContent.style.color = props.textColor;
                if (props.textAlign) newContent.style.textAlign = props.textAlign;
                break;
                
            case 'textfield':
                if (props.placeholder) newContent.placeholder = props.placeholder;
                if (props.borderColor) newContent.style.borderColor = props.borderColor;
                break;
                
            case 'image':
                const img = newContent.querySelector('img');
                if (img) {
                    if (props.src) img.src = props.src;
                    if (props.alt) img.alt = props.alt;
                }
                break;
        }
    }

    deleteComponent() {
        if (!this.selectedComponent) return;
        
        this.saveState();
        
        const element = document.getElementById(this.selectedComponent);
        if (element) {
            element.remove();
        }
        
        this.components.delete(this.selectedComponent);
        this.selectedComponent = null;
        this.showNoSelectionMessage();
        this.saveToStorage();
    }

    clearCanvas() {
        this.saveState();
        
        const canvas = document.getElementById('designCanvas');
        canvas.innerHTML = '<div class="drop-zone"></div>';
        
        this.components.clear();
        this.selectedComponent = null;
        this.componentCounter = 0;
        this.showNoSelectionMessage();
        this.saveToStorage();
    }

    saveState() {
        const state = {
            components: Array.from(this.components.entries()),
            componentCounter: this.componentCounter
        };
        
        this.undoStack.push(JSON.stringify(state));
        if (this.undoStack.length > this.maxUndoSteps) {
            this.undoStack.shift();
        }
        
        this.redoStack = []; // Clear redo stack
    }

    undo() {
        if (this.undoStack.length === 0) return;
        
        // Save current state to redo stack
        const currentState = {
            components: Array.from(this.components.entries()),
            componentCounter: this.componentCounter
        };
        this.redoStack.push(JSON.stringify(currentState));
        
        // Restore previous state
        const previousState = JSON.parse(this.undoStack.pop());
        this.components = new Map(previousState.components);
        this.componentCounter = previousState.componentCounter;
        
        this.rerenderCanvas();
        this.deselectAll();
        this.saveToStorage();
    }

    redo() {
        if (this.redoStack.length === 0) return;
        
        // Save current state to undo stack
        const currentState = {
            components: Array.from(this.components.entries()),
            componentCounter: this.componentCounter
        };
        this.undoStack.push(JSON.stringify(currentState));
        
        // Restore next state
        const nextState = JSON.parse(this.redoStack.pop());
        this.components = new Map(nextState.components);
        this.componentCounter = nextState.componentCounter;
        
        this.rerenderCanvas();
        this.deselectAll();
        this.saveToStorage();
    }

    rerenderCanvas() {
        const canvas = document.getElementById('designCanvas');
        canvas.innerHTML = '<div class="drop-zone"></div>';
        
        this.components.forEach(component => {
            this.renderComponent(component);
        });
    }

    handleKeydown(e) {
        if (e.ctrlKey || e.metaKey) {
            switch (e.key) {
                case 'z':
                    e.preventDefault();
                    if (e.shiftKey) {
                        this.redo();
                    } else {
                        this.undo();
                    }
                    break;
                case 'y':
                    e.preventDefault();
                    this.redo();
                    break;
            }
        }
        
        if (e.key === 'Delete' || e.key === 'Backspace') {
            if (this.selectedComponent && e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
                e.preventDefault();
                this.deleteComponent();
            }
        }
    }

    handleResize() {
        // Handle responsive behavior if needed
    }

    // Touch event handlers for mobile support
    handlePaletteTouchStart(e) {
        e.preventDefault();
        const paletteItem = e.target.closest('.palette-item');
        if (!paletteItem) return;
        
        const touch = e.touches[0];
        const componentType = paletteItem.dataset.component;
        
        this.touchState = {
            isDragging: true,
            dragElement: null,
            startX: touch.clientX,
            startY: touch.clientY,
            offsetX: 0,
            offsetY: 0,
            componentType: componentType
        };
        
        // Create visual feedback
        paletteItem.classList.add('dragging');
        const canvas = document.getElementById('designCanvas');
        canvas.classList.add('drag-active');
        
        // Create drag ghost for touch
        const ghost = this.createDragGhost(paletteItem, componentType);
        ghost.style.position = 'fixed';
        ghost.style.left = touch.clientX - 40 + 'px';
        ghost.style.top = touch.clientY - 25 + 'px';
        ghost.style.zIndex = '10000';
        ghost.style.pointerEvents = 'none';
        document.body.appendChild(ghost);
        
        this.touchState.dragElement = ghost;
    }

    handlePaletteTouchMove(e) {
        if (!this.touchState.isDragging) return;
        e.preventDefault();
        
        const touch = e.touches[0];
        const ghost = this.touchState.dragElement;
        
        if (ghost) {
            ghost.style.left = touch.clientX - 40 + 'px';
            ghost.style.top = touch.clientY - 25 + 'px';
        }
        
        // Visual feedback for canvas
        const canvas = document.getElementById('designCanvas');
        const canvasRect = canvas.getBoundingClientRect();
        
        if (touch.clientX >= canvasRect.left && touch.clientX <= canvasRect.right &&
            touch.clientY >= canvasRect.top && touch.clientY <= canvasRect.bottom) {
            canvas.classList.add('drag-over');
        } else {
            canvas.classList.remove('drag-over');
        }
    }

    handlePaletteTouchEnd(e) {
        if (!this.touchState.isDragging) return;
        e.preventDefault();
        
        const touch = e.changedTouches[0];
        const canvas = document.getElementById('designCanvas');
        const canvasRect = canvas.getBoundingClientRect();
        
        // Check if dropped on canvas
        if (touch.clientX >= canvasRect.left && touch.clientX <= canvasRect.right &&
            touch.clientY >= canvasRect.top && touch.clientY <= canvasRect.bottom) {
            
            const x = touch.clientX - canvasRect.left - 20;
            const y = touch.clientY - canvasRect.top - 20;
            
            this.createComponent(this.touchState.componentType, x, y);
        }
        
        // Clean up
        if (this.touchState.dragElement) {
            document.body.removeChild(this.touchState.dragElement);
        }
        
        const paletteItems = document.querySelectorAll('.palette-item.dragging');
        paletteItems.forEach(item => item.classList.remove('dragging'));
        
        canvas.classList.remove('drag-active', 'drag-over');
        
        this.touchState = {
            isDragging: false,
            dragElement: null,
            startX: 0,
            startY: 0,
            offsetX: 0,
            offsetY: 0,
            componentType: null
        };
    }

    handleCanvasTouchStart(e) {
        const target = e.target.closest('.draggable-component');
        if (!target) return;
        
        e.preventDefault();
        const touch = e.touches[0];
        const componentId = target.id;
        
        this.selectComponent(componentId);
        this.saveState();
        
        const rect = target.getBoundingClientRect();
        this.touchState = {
            isDragging: true,
            dragElement: target,
            startX: touch.clientX,
            startY: touch.clientY,
            offsetX: touch.clientX - rect.left,
            offsetY: touch.clientY - rect.top,
            componentType: null
        };
        
        target.classList.add('dragging');
    }

    handleCanvasTouchMove(e) {
        if (!this.touchState.isDragging || !this.touchState.dragElement) return;
        e.preventDefault();
        
        const touch = e.touches[0];
        const component = this.touchState.dragElement;
        const canvas = document.getElementById('designCanvas');
        const canvasRect = canvas.getBoundingClientRect();
        
        const newX = touch.clientX - canvasRect.left - this.touchState.offsetX;
        const newY = touch.clientY - canvasRect.top - this.touchState.offsetY;
        
        const componentWidth = parseInt(component.style.width);
        const componentHeight = parseInt(component.style.height);
        
        const maxLeft = canvasRect.width - componentWidth - 20;
        const maxTop = canvasRect.height - componentHeight - 20;
        
        const clampedX = Math.max(0, Math.min(maxLeft, newX));
        const clampedY = Math.max(0, Math.min(maxTop, newY));
        
        component.style.left = clampedX + 'px';
        component.style.top = clampedY + 'px';
        
        // Update component data
        const componentData = this.components.get(component.id);
        if (componentData) {
            componentData.x = clampedX;
            componentData.y = clampedY;
        }
    }

    handleCanvasTouchEnd(e) {
        if (!this.touchState.isDragging) return;
        e.preventDefault();
        
        if (this.touchState.dragElement) {
            this.touchState.dragElement.classList.remove('dragging');
        }
        
        this.touchState = {
            isDragging: false,
            dragElement: null,
            startX: 0,
            startY: 0,
            offsetX: 0,
            offsetY: 0,
            componentType: null
        };
        
        this.updatePropertiesPanel();
        this.saveToStorage();
    }

    saveToStorage() {
        const data = {
            components: Array.from(this.components.entries()),
            componentCounter: this.componentCounter
        };
        localStorage.setItem('dragDropDesigner', JSON.stringify(data));
    }

    loadFromStorage() {
        const saved = localStorage.getItem('dragDropDesigner');
        if (saved) {
            try {
                const data = JSON.parse(saved);
                this.components = new Map(data.components || []);
                this.componentCounter = data.componentCounter || 0;
                this.rerenderCanvas();
            } catch (e) {
                console.warn('Failed to load saved design:', e);
            }
        }
    }

    loadSavedLayouts() {
        try {
            const saved = localStorage.getItem('saved_layouts');
            if (saved) {
                const layouts = JSON.parse(saved);
                this.savedLayouts = new Map(layouts);
            }
        } catch (error) {
            console.error('Error loading saved layouts:', error);
        }
    }

    setupAIControls() {
        // Remove existing AI controls to prevent duplicates
        const existingControls = document.querySelector('.ai-controls');
        if (existingControls) {
            existingControls.remove();
        }
        
        // Add AI controls to properties panel
        const aiControlsHTML = `
            <div class="ai-controls" style="margin-top: 20px; padding: 15px; border: 1px solid #ddd; border-radius: 8px; background: #f9f9f9;">
                <h4 style="margin: 0 0 10px 0; color: #333;">🤖 AI Styling</h4>
                <div class="ai-input-group" style="margin-bottom: 10px;">
                    <input type="text" id="aiPrompt" placeholder="e.g., Make this button blue and rounded" 
                           style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; margin-bottom: 8px;">
                    <button id="applyAIStyling" style="width: 100%; padding: 8px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">Apply AI Styling</button>
                </div>
                <div class="ai-palette-group">
                    <select id="themeSelect" style="width: 60%; padding: 6px; margin-right: 5px; border: 1px solid #ccc; border-radius: 4px;">
                        <option value="modern">Modern</option>
                        <option value="dark">Dark</option>
                        <option value="pastel">Pastel</option>
                        <option value="vibrant">Vibrant</option>
                        <option value="minimal">Minimal</option>
                    </select>
                    <button id="generatePalette" style="width: 35%; padding: 6px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;">Generate</button>
                </div>
                <div class="api-key-group" style="margin-top: 10px;">
                    <input type="password" id="aiApiKey" placeholder="OpenAI API Key (optional)" 
                           style="width: 100%; padding: 6px; border: 1px solid #ccc; border-radius: 4px; font-size: 12px;">
                </div>
            </div>
        `;
        
        // Insert AI controls after properties panel content
        const propertiesPanel = document.getElementById('propertiesPanel');
        if (propertiesPanel) {
            propertiesPanel.insertAdjacentHTML('beforeend', aiControlsHTML);
            
            // Bind AI control events
            document.getElementById('applyAIStyling').addEventListener('click', this.handleAIStyling.bind(this));
            document.getElementById('generatePalette').addEventListener('click', this.handleGeneratePalette.bind(this));
            document.getElementById('aiApiKey').addEventListener('change', this.handleApiKeyChange.bind(this));
            
            // Load saved API key
            const savedKey = this.aiService.getApiKey();
            if (savedKey) {
                document.getElementById('aiApiKey').value = savedKey;
            }
        }
    }

    setupLayoutManager() {
        // Add layout manager to toolbar
        const toolbar = document.querySelector('.toolbar');
        if (toolbar && !document.querySelector('.layout-manager')) {
            const layoutManagerHTML = `
                <div class="layout-manager" style="display: inline-block; margin-left: 15px;">
                    <button id="saveLayoutBtn" class="toolbar-btn" title="Save Current Layout">
                        💾 Save Layout
                    </button>
                    <button id="loadLayoutBtn" class="toolbar-btn" title="Load Saved Layout">
                        📁 Load Layout
                    </button>
                    <button id="manageLayoutsBtn" class="toolbar-btn" title="Manage Layouts">
                        📋 Manage
                    </button>
                </div>
            `;
            
            toolbar.insertAdjacentHTML('beforeend', layoutManagerHTML);
            
            // Bind layout manager events
            document.getElementById('saveLayoutBtn').addEventListener('click', this.showSaveLayoutDialog.bind(this));
            document.getElementById('loadLayoutBtn').addEventListener('click', this.showLoadLayoutDialog.bind(this));
            document.getElementById('manageLayoutsBtn').addEventListener('click', this.showLayoutManager.bind(this));
        }
    }

    async handleAIStyling() {
        if (!this.selectedComponent) {
            alert('Please select a component first');
            return;
        }

        const prompt = document.getElementById('aiPrompt').value.trim();
        if (!prompt) {
            alert('Please enter a styling request');
            return;
        }

        const component = this.components.get(this.selectedComponent);
        if (!component) return;

        try {
            // Show loading state
            const button = document.getElementById('applyAIStyling');
            const originalText = button.textContent;
            button.textContent = 'Applying...';
            button.disabled = true;

            const newProperties = await this.aiService.generateStyling(prompt, component.properties);
            
            // Apply the AI-generated properties
            Object.assign(component.properties, newProperties);
            
            // Update the component
            this.updateComponentElement(component);
            this.updatePropertiesPanel();
            this.saveState();
            this.saveToStorage();
            
            // Clear the prompt
            document.getElementById('aiPrompt').value = '';
            
            // Restore button state
            button.textContent = originalText;
            button.disabled = false;
            
        } catch (error) {
            alert(`AI Styling Error: ${error.message}`);
            // Restore button state
            const button = document.getElementById('applyAIStyling');
            button.textContent = 'Apply AI Styling';
            button.disabled = false;
        }
    }

    async handleGeneratePalette() {
        const theme = document.getElementById('themeSelect').value;
        
        try {
            const button = document.getElementById('generatePalette');
            const originalText = button.textContent;
            button.textContent = 'Generating...';
            button.disabled = true;

            const palette = await this.aiService.suggestColorPalette(theme);
            
            // Apply palette to selected component or show palette
            if (this.selectedComponent) {
                const component = this.components.get(this.selectedComponent);
                if (component) {
                    // Apply primary color as background, text color as text
                    component.properties.backgroundColor = palette.primary || palette.background;
                    component.properties.color = palette.text;
                    
                    this.updateComponentElement(component);
                    this.updatePropertiesPanel();
                    this.saveState();
                    this.saveToStorage();
                }
            } else {
                // Show palette in a modal or alert
                const paletteText = Object.entries(palette)
                    .map(([key, value]) => `${key}: ${value}`)
                    .join('\n');
                alert(`Generated ${theme} palette:\n\n${paletteText}`);
            }
            
            button.textContent = originalText;
            button.disabled = false;
            
        } catch (error) {
            alert(`Palette Generation Error: ${error.message}`);
            const button = document.getElementById('generatePalette');
            button.textContent = 'Generate';
            button.disabled = false;
        }
    }

    handleApiKeyChange(e) {
        const apiKey = e.target.value.trim();
        if (apiKey) {
            this.aiService.setApiKey(apiKey);
        }
    }

    showSaveLayoutDialog() {
        const name = prompt('Enter a name for this layout:');
        if (name && name.trim()) {
            this.saveLayout(name.trim());
        }
    }

    saveLayout(name) {
        const layoutData = {
            components: Array.from(this.components.entries()),
            componentCounter: this.componentCounter,
            timestamp: Date.now()
        };
        
        this.savedLayouts.set(name, layoutData);
        
        // Save to localStorage
        try {
            localStorage.setItem('saved_layouts', JSON.stringify(Array.from(this.savedLayouts.entries())));
            alert(`Layout "${name}" saved successfully!`);
        } catch (error) {
            console.error('Error saving layout:', error);
            alert('Error saving layout');
        }
    }

    showLoadLayoutDialog() {
        if (this.savedLayouts.size === 0) {
            alert('No saved layouts found');
            return;
        }

        const layoutNames = Array.from(this.savedLayouts.keys());
        const choice = prompt(`Select a layout to load:\n\n${layoutNames.map((name, i) => `${i + 1}. ${name}`).join('\n')}\n\nEnter the number or name:`);
        
        if (choice) {
            const index = parseInt(choice) - 1;
            const layoutName = isNaN(index) ? choice : layoutNames[index];
            
            if (this.savedLayouts.has(layoutName)) {
                this.loadLayout(layoutName);
            } else {
                alert('Layout not found');
            }
        }
    }

    loadLayout(name) {
        const layoutData = this.savedLayouts.get(name);
        if (!layoutData) {
            alert('Layout not found');
            return;
        }

        // Clear current canvas
        this.clearCanvas();
        
        // Load layout data
        this.components = new Map(layoutData.components);
        this.componentCounter = layoutData.componentCounter;
        
        // Re-render canvas
        this.rerenderCanvas();
        this.saveToStorage();
        
        alert(`Layout "${name}" loaded successfully!`);
    }

    showLayoutManager() {
        if (this.savedLayouts.size === 0) {
            alert('No saved layouts found');
            return;
        }

        const layouts = Array.from(this.savedLayouts.entries());
        const layoutList = layouts.map(([name, data], i) => {
            const date = new Date(data.timestamp).toLocaleDateString();
            const componentCount = data.components.length;
            return `${i + 1}. ${name} (${componentCount} components, saved ${date})`;
        }).join('\n');

        const action = prompt(`Layout Manager:\n\n${layoutList}\n\nActions:\n- Enter number + 'L' to load (e.g., '1L')\n- Enter number + 'D' to delete (e.g., '1D')\n- Enter 'C' to cancel`);

        if (action && action.toLowerCase() !== 'c') {
            const match = action.match(/(\d+)([LD])/i);
            if (match) {
                const index = parseInt(match[1]) - 1;
                const operation = match[2].toUpperCase();
                const layoutName = layouts[index]?.[0];

                if (layoutName) {
                    if (operation === 'L') {
                        this.loadLayout(layoutName);
                    } else if (operation === 'D') {
                        if (confirm(`Delete layout "${layoutName}"?`)) {
                            this.deleteLayout(layoutName);
                        }
                    }
                }
            }
        }
    }

    deleteLayout(name) {
        this.savedLayouts.delete(name);
        try {
            localStorage.setItem('saved_layouts', JSON.stringify(Array.from(this.savedLayouts.entries())));
            alert(`Layout "${name}" deleted successfully!`);
        } catch (error) {
            console.error('Error deleting layout:', error);
            alert('Error deleting layout');
        }
    }

    handleResizeStart(handle, e) {
        e.preventDefault();
        e.stopPropagation();
        
        const component = e.target.closest('.draggable-component');
        const componentId = component.id;
        const componentData = this.components.get(componentId);
        
        if (!componentData) return;
        
        this.saveState(); // Save state for undo
        
        const canvas = document.getElementById('designCanvas');
        const canvasRect = canvas.getBoundingClientRect();
        
        const startX = e.clientX;
        const startY = e.clientY;
        const startWidth = componentData.width;
        const startHeight = componentData.height;
        const startLeft = componentData.x;
        const startTop = componentData.y;
        
        // Add resize cursor to body
        document.body.style.cursor = e.target.style.cursor;
        
        const handleMouseMove = (e) => {
            const deltaX = e.clientX - startX;
            const deltaY = e.clientY - startY;
            
            let newWidth = startWidth;
            let newHeight = startHeight;
            let newLeft = startLeft;
            let newTop = startTop;
            
            const minSize = 20;
            const maxWidth = canvasRect.width - newLeft;
            const maxHeight = canvasRect.height - newTop;
            
            switch (handle) {
                case 'se':
                    newWidth = Math.max(minSize, Math.min(maxWidth, startWidth + deltaX));
                    newHeight = Math.max(minSize, Math.min(maxHeight, startHeight + deltaY));
                    break;
                case 'sw':
                    newWidth = Math.max(minSize, startWidth - deltaX);
                    newHeight = Math.max(minSize, Math.min(maxHeight, startHeight + deltaY));
                    newLeft = Math.max(0, Math.min(startLeft + deltaX, startLeft + startWidth - minSize));
                    break;
                case 'ne':
                    newWidth = Math.max(minSize, Math.min(maxWidth, startWidth + deltaX));
                    newHeight = Math.max(minSize, startHeight - deltaY);
                    newTop = Math.max(0, Math.min(startTop + deltaY, startTop + startHeight - minSize));
                    break;
                case 'nw':
                    newWidth = Math.max(minSize, startWidth - deltaX);
                    newHeight = Math.max(minSize, startHeight - deltaY);
                    newLeft = Math.max(0, Math.min(startLeft + deltaX, startLeft + startWidth - minSize));
                    newTop = Math.max(0, Math.min(startTop + deltaY, startTop + startHeight - minSize));
                    break;
                case 'n':
                    newHeight = Math.max(minSize, startHeight - deltaY);
                    newTop = Math.max(0, Math.min(startTop + deltaY, startTop + startHeight - minSize));
                    break;
                case 's':
                    newHeight = Math.max(minSize, Math.min(maxHeight, startHeight + deltaY));
                    break;
                case 'e':
                    newWidth = Math.max(minSize, Math.min(maxWidth, startWidth + deltaX));
                    break;
                case 'w':
                    newWidth = Math.max(minSize, startWidth - deltaX);
                    newLeft = Math.max(0, Math.min(startLeft + deltaX, startLeft + startWidth - minSize));
                    break;
            }
            
            componentData.width = newWidth;
            componentData.height = newHeight;
            componentData.x = newLeft;
            componentData.y = newTop;
            
            component.style.width = newWidth + 'px';
            component.style.height = newHeight + 'px';
            component.style.left = newLeft + 'px';
            component.style.top = newTop + 'px';
        };
        
        const handleMouseUp = () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
            document.body.style.cursor = '';
            this.updatePropertiesPanel();
            this.saveToStorage();
        };
        
        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
    }
}

// Initialize the designer when DOM is loaded
let designer;
document.addEventListener('DOMContentLoaded', () => {
    designer = new DragDropDesigner();
});