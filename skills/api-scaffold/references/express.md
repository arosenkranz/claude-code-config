# Express/TypeScript Template

## Application Template

```typescript
import express from 'express';
import tracer from 'dd-trace';

// Initialize Datadog tracer
tracer.init({
  service: 'training-api',
  env: process.env.DD_ENV || 'development'
});

const app = express();
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'training-api' });
});

// Products API with tracing
app.get('/api/products', async (req, res) => {
  const span = tracer.startSpan('get_products');

  try {
    // Simulate database call
    const dbSpan = tracer.startSpan('database.query', { childOf: span });
    dbSpan.setTag('query.type', 'select');

    const products = [
      { id: 1, name: 'Widget', price: 9.99 },
      { id: 2, name: 'Gadget', price: 19.99 }
    ];

    dbSpan.finish();

    console.log(`Retrieved ${products.length} products`);
    res.json({ products });
  } catch (error) {
    span.setTag('error', true);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    span.finish();
  }
});

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```
