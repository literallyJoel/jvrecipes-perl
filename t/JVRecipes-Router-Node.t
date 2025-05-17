tap.beforeEach(done => {
  // Reset DB stub for each test
  delete require.cache[require.resolve('../lib/db')];
  require.cache[require.resolve('../lib/db')] = {
    exports: {
      getRecipeById: async id => ({ id, name: 'Test' }),
      createRecipe: async data => ({ id: '123', ...data }),
      updateRecipe: async (id, data) => ({ id, ...data }),
      deleteRecipe: async id => true
    }
  };
  done();
});

tap.afterEach(done => {
  // Clean up any require.cache overrides
  delete require.cache[require.resolve('../lib/db')];
  done();
});

tap.test('getRecipeById • returns 200 and recipe object when ID is valid', async t => {
  const fakeReq = { params: { id: '123' } };
  const fakeRes = {
    statusCode: null,
    body: null,
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.body = payload; return this; }
  };
  await router.getRecipeById(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 200, 'statusCode should be 200');
  t.same(fakeRes.body, { id: '123', name: 'Test' }, 'response body matches stub');
  t.end();
});

tap.test('getRecipeById • returns 400 when ID is missing', async t => {
  const fakeReq = { params: {} };
  const fakeRes = {
    status(code) { t.equal(code, 400, 'status should be 400'); return this; },
    json(payload) { t.match(payload.message, /missing id/i, 'error message indicates missing id'); t.end(); }
  };
  await router.getRecipeById(fakeReq, fakeRes);
});

tap.test('getRecipeById • returns 404 when recipe not found', async t => {
  // Stub DB for not found
  delete require.cache[require.resolve('../lib/db')];
  require.cache[require.resolve('../lib/db')] = {
    exports: { getRecipeById: async () => null }
  };
  const fakeReq = { params: { id: '999' } };
  const fakeRes = {
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.payload = payload; return this; }
  };
  await router.getRecipeById(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 404, 'statusCode should be 404');
  t.match(fakeRes.payload.message, /not found/i, 'error message indicates not found');
  t.end();
});

tap.test('createRecipe • returns 201 and created recipe when payload is valid', async t => {
  const fakeReq = { body: { name: 'Soup', description: 'Hot soup' } };
  const fakeRes = {
    statusCode: null,
    body: null,
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.body = payload; return this; }
  };
  await router.createRecipe(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 201, 'statusCode should be 201');
  t.same(fakeRes.body, { id: '123', name: 'Soup', description: 'Hot soup' }, 'response body matches stub');
  t.end();
});

tap.test('createRecipe • returns 400 when payload is invalid', async t => {
  const fakeReq = { body: { name: '', description: '' } };
  const fakeRes = {
    status(code) { t.equal(code, 400, 'status should be 400'); return this; },
    json(payload) { t.match(payload.message, /invalid payload/i, 'error message indicates invalid payload'); t.end(); }
  };
  await router.createRecipe(fakeReq, fakeRes);
});

tap.test('createRecipe • returns 500 when DB error occurs', async t => {
  delete require.cache[require.resolve('../lib/db')];
  require.cache[require.resolve('../lib/db')] = {
    exports: { createRecipe: async () => { throw new Error('DB failure'); } }
  };
  const fakeReq = { body: { name: 'X', description: 'Y' } };
  const fakeRes = {
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.payload = payload; return this; }
  };
  await router.createRecipe(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 500, 'statusCode should be 500');
  t.match(fakeRes.payload.message, /db failure/i, 'error message propagates DB error');
  t.end();
});

tap.test('updateRecipe • returns 200 and updated recipe when ID and payload are valid', async t => {
  const fakeReq = { params: { id: '123' }, body: { name: 'Pie', description: 'Apple pie' } };
  const fakeRes = {
    statusCode: null,
    body: null,
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.body = payload; return this; }
  };
  await router.updateRecipe(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 200, 'statusCode should be 200');
  t.same(fakeRes.body, { id: '123', name: 'Pie', description: 'Apple pie' }, 'response body matches stub');
  t.end();
});

tap.test('updateRecipe • returns 400 when ID is missing or payload is invalid', async t => {
  const fakeReq = { params: {}, body: {} };
  const fakeRes = {
    status(code) { t.equal(code, 400, 'status should be 400'); return this; },
    json(payload) { t.match(payload.message, /invalid input|missing id/i, 'error message indicates invalid input'); t.end(); }
  };
  await router.updateRecipe(fakeReq, fakeRes);
});

tap.test('updateRecipe • returns 404 when recipe not found', async t => {
  delete require.cache[require.resolve('../lib/db')];
  require.cache[require.resolve('../lib/db')] = {
    exports: { updateRecipe: async () => null }
  };
  const fakeReq = { params: { id: '999' }, body: { name: 'Test', description: 'Desc' } };
  const fakeRes = {
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.payload = payload; return this; }
  };
  await router.updateRecipe(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 404, 'statusCode should be 404');
  t.match(fakeRes.payload.message, /not found/i, 'error message indicates not found');
  t.end();
});

tap.test('deleteRecipe • returns 204 when deletion is successful', async t => {
  const fakeReq = { params: { id: '123' } };
  const fakeRes = {
    statusCode: null,
    endCalled: false,
    status(code) { this.statusCode = code; return this; },
    end() { this.endCalled = true; return this; }
  };
  await router.deleteRecipe(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 204, 'statusCode should be 204');
  t.equal(fakeRes.endCalled, true, 'end should be called');
  t.end();
});

tap.test('deleteRecipe • returns 404 when recipe not found', async t => {
  delete require.cache[require.resolve('../lib/db')];
  require.cache[require.resolve('../lib/db')] = {
    exports: { deleteRecipe: async () => false }
  };
  const fakeReq = { params: { id: '999' } };
  const fakeRes = {
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.payload = payload; return this; }
  };
  await router.deleteRecipe(fakeReq, fakeRes);
  t.equal(fakeRes.statusCode, 404, 'statusCode should be 404');
  t.match(fakeRes.payload.message, /not found/i, 'error message indicates not found');
  t.end();
});

tap.test('deleteRecipe • returns 400 when ID is missing', async t => {
  const fakeReq = { params: {} };
  const fakeRes = {
    status(code) { t.equal(code, 400, 'status should be 400'); return this; },
    json(payload) { t.match(payload.message, /missing id/i, 'error message indicates missing id'); t.end(); }
  };
  await router.deleteRecipe(fakeReq, fakeRes);
});