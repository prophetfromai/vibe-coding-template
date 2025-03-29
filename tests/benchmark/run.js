/**
 * Simple benchmark utility for measuring performance
 */

// Import utilities to benchmark
const dateUtils = require('../../src/utils/formatting/dateFormat');

// Test data
const dates = [
  new Date(),
  new Date('2023-01-01'),
  new Date('2022-06-15T12:30:45'),
  new Date('2020-12-25'),
  '2023-05-20T10:15:30',
  '2021-03-17',
  1672531200000, // 2023-01-01 in milliseconds
];

// Time measurement helper
function measureExecutionTime(fn, iterations = 10000) {
  const start = performance.now();
  
  for (let i = 0; i < iterations; i++) {
    fn();
  }
  
  const end = performance.now();
  return end - start;
}

// Run benchmarks for formatDate function
function benchmarkFormatDate() {
  console.log('\n=== Benchmarking formatDate ===');
  
  // Test different formats
  const formats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];
  
  formats.forEach(format => {
    const time = measureExecutionTime(() => {
      dates.forEach(date => {
        dateUtils.formatDate(date, format);
      });
    });
    
    console.log(`Format: ${format} - ${time.toFixed(2)}ms for ${dates.length * 10000} operations`);
  });
}

// Run benchmarks for formatRelativeTime function
function benchmarkFormatRelativeTime() {
  console.log('\n=== Benchmarking formatRelativeTime ===');
  
  const time = measureExecutionTime(() => {
    dates.forEach(date => {
      dateUtils.formatRelativeTime(date);
    });
  });
  
  console.log(`${time.toFixed(2)}ms for ${dates.length * 10000} operations`);
}

// Run benchmarks for formatDateTime function
function benchmarkFormatDateTime() {
  console.log('\n=== Benchmarking formatDateTime ===');
  
  // Test different time formats
  const timeFormats = ['12h', '24h'];
  
  timeFormats.forEach(timeFormat => {
    const time = measureExecutionTime(() => {
      dates.forEach(date => {
        dateUtils.formatDateTime(date, 'MM/DD/YYYY', timeFormat);
      });
    });
    
    console.log(`Time format: ${timeFormat} - ${time.toFixed(2)}ms for ${dates.length * 10000} operations`);
  });
}

// Run all benchmarks
function runAllBenchmarks() {
  console.log('Running performance benchmarks...');
  
  benchmarkFormatDate();
  benchmarkFormatRelativeTime();
  benchmarkFormatDateTime();
  
  console.log('\nBenchmarks completed!');
}

// Execute benchmark
runAllBenchmarks(); 