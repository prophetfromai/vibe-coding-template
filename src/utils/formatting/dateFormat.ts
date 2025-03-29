/**
 * Date formatting utilities
 */

/**
 * Format a date to a string using the specified format
 * This is a simplified implementation - in a real project, use a library like date-fns
 * 
 * @param date - Date to format
 * @param format - Format string (MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD)
 * @returns Formatted date string
 */
export function formatDate(
  date: Date | string | number,
  format = 'MM/DD/YYYY'
): string {
  const dateObj = date instanceof Date ? date : new Date(date);
  
  // Check if date is valid
  if (isNaN(dateObj.getTime())) {
    return 'Invalid Date';
  }

  const day = String(dateObj.getDate()).padStart(2, '0');
  const month = String(dateObj.getMonth() + 1).padStart(2, '0');
  const year = String(dateObj.getFullYear());

  // Replace format tokens with actual values
  return format
    .replace('DD', day)
    .replace('MM', month)
    .replace('YYYY', year);
}

/**
 * Format a date to a relative time string (e.g., "5 minutes ago")
 * 
 * @param date - Date to format
 * @returns Relative time string
 */
export function formatRelativeTime(date: Date | string | number): string {
  const dateObj = date instanceof Date ? date : new Date(date);
  
  // Check if date is valid
  if (isNaN(dateObj.getTime())) {
    return 'Invalid Date';
  }

  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - dateObj.getTime()) / 1000);

  // Less than a minute
  if (diffInSeconds < 60) {
    return 'just now';
  }

  // Less than an hour
  if (diffInSeconds < 3600) {
    const minutes = Math.floor(diffInSeconds / 60);
    return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
  }

  // Less than a day
  if (diffInSeconds < 86400) {
    const hours = Math.floor(diffInSeconds / 3600);
    return `${hours} hour${hours > 1 ? 's' : ''} ago`;
  }

  // Less than a week
  if (diffInSeconds < 604800) {
    const days = Math.floor(diffInSeconds / 86400);
    return `${days} day${days > 1 ? 's' : ''} ago`;
  }

  // Less than a month
  if (diffInSeconds < 2592000) {
    const weeks = Math.floor(diffInSeconds / 604800);
    return `${weeks} week${weeks > 1 ? 's' : ''} ago`;
  }

  // Less than a year
  if (diffInSeconds < 31536000) {
    const months = Math.floor(diffInSeconds / 2592000);
    return `${months} month${months > 1 ? 's' : ''} ago`;
  }

  // More than a year
  const years = Math.floor(diffInSeconds / 31536000);
  return `${years} year${years > 1 ? 's' : ''} ago`;
}

/**
 * Format a date to include the time
 * 
 * @param date - Date to format
 * @param format - Date format
 * @param timeFormat - Time format (12h or 24h)
 * @returns Formatted date and time string
 */
export function formatDateTime(
  date: Date | string | number,
  format = 'MM/DD/YYYY',
  timeFormat = '12h'
): string {
  const dateObj = date instanceof Date ? date : new Date(date);
  
  // Check if date is valid
  if (isNaN(dateObj.getTime())) {
    return 'Invalid Date';
  }

  const formattedDate = formatDate(dateObj, format);
  
  // Format time based on 12h or 24h format
  let hours = dateObj.getHours();
  const minutes = String(dateObj.getMinutes()).padStart(2, '0');
  
  if (timeFormat === '12h') {
    const period = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12; // Convert 0 to 12 for 12h format
    return `${formattedDate} ${hours}:${minutes} ${period}`;
  }
  
  // 24h format
  return `${formattedDate} ${String(hours).padStart(2, '0')}:${minutes}`;
} 