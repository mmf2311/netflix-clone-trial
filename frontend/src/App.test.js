import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import App from './App';

test('renders Netflix Clone header', () => {
  render(<App />);
  const headerElement = screen.getByText(/Netflix Clone/i);
  expect(headerElement).toBeInTheDocument();
});
