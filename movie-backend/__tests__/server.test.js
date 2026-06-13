process.env.TMDB_API_KEY   = 'test-key';
process.env.AI_SERVICE_BASE = 'http://ml:5000';
process.env.AI_SERVICE_KEY  = 'svc-key';

const mockQuery = jest.fn();
jest.mock('pg', () => ({ Pool: jest.fn(() => ({ query: mockQuery })) }));
jest.mock('axios');

const request = require('supertest');
const axios = require('axios');
const { app } = require('../server');

beforeEach(() => jest.clearAllMocks());

describe('GET /movies', () => {
  it('maps TMDB popular results to {id,title,posterURL}', async () => {
    axios.get.mockResolvedValue({ data: { results: [{ id: 1, title: 'A', poster_path: '/p.jpg' }] } });
    const res = await request(app).get('/movies');
    expect(res.status).toBe(200);
    expect(res.body[0]).toEqual({ id: 1, title: 'A', posterURL: 'https://image.tmdb.org/t/p/w500/p.jpg' });
  });
  it('returns [] on TMDB failure', async () => {
    axios.get.mockRejectedValue(new Error('boom'));
    const res = await request(app).get('/movies');
    expect(res.status).toBe(500);
    expect(res.body).toEqual([]);
  });
});

describe('GET /movie/:id', () => {
  it('returns TMDB movie detail', async () => {
    axios.get.mockResolvedValue({ data: { id: 550, title: 'Fight Club' } });
    const res = await request(app).get('/movie/550');
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('Fight Club');
  });
});

describe('POST /users/importOrGetId', () => {
  it('400 when firebaseUid missing', async () => {
    const res = await request(app).post('/users/importOrGetId').send({});
    expect(res.status).toBe(400);
  });
  it('returns userId from db', async () => {
    mockQuery.mockResolvedValue({ rows: [{ id: 14 }] });
    const res = await request(app).post('/users/importOrGetId').send({ firebaseUid: 'u', displayName: 'n' });
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ userId: 14 });
  });
});

describe('POST /swipes', () => {
  it('records a swipe', async () => {
    mockQuery.mockResolvedValue({});
    const res = await request(app).post('/swipes').send({ userId: 14, movieId: 1, direction: 'like' });
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ success: true });
  });
});


describe('GET /recommendations/:kind/:userId', () => {
  it('proxies hybrid recs from the ML service', async () => {
    axios.get.mockResolvedValue({ data: [{ id: 1, title: 'X' }] });
    const res = await request(app).get('/recommendations/hybrid/14');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([{ id: 1, title: 'X' }]);
  });
  it('returns the ML error status with [] body', async () => {
    axios.get.mockRejectedValue({ response: { status: 502 } });
    const res = await request(app).get('/recommendations/cf/14');
    expect(res.status).toBe(502);
    expect(res.body).toEqual([]);
  });
});

describe('GET /users/:userId/likes', () => {
  it('returns hydrated liked movies', async () => {
    mockQuery.mockResolvedValue({ rows: [{ movie_id: 550 }] });
    axios.get.mockResolvedValue({ data: { id: 550, title: 'Fight Club' } });
    const res = await request(app).get('/users/14/likes');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([{ id: 550, title: 'Fight Club' }]);
  });
  it('returns [] when user has no likes', async () => {
    mockQuery.mockResolvedValue({ rows: [] });
    const res = await request(app).get('/users/14/likes');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });
});
