// src/App.test.js
import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({ results: [] }),
  })
);

test('renders Netflix Clone header', () => {
  render(<App />);
  const linkElement = screen.getByText(/Netflix Clone/i);
  expect(linkElement).toBeInTheDocument();
});
