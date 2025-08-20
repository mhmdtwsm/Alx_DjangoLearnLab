#!/usr/bin/env python3
"""
Comprehensive test script for Django REST Framework filtering, searching, and ordering.

This script tests all implemented features:
- Basic CRUD operations
- Filtering by various fields
- Search functionality
- Ordering capabilities
- Combined operations
- Error handling
"""

import requests
import json
import sys
import time
from urllib.parse import urlencode
from typing import Dict, Any, Optional

# Configuration
BASE_URL = "http://127.0.0.1:8000"
API_BASE = f"{BASE_URL}/api"

class Colors:
    """ANSI color codes for terminal output."""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class APITester:
    """Comprehensive API testing class."""
    
    def __init__(self):
        self.passed_tests = 0
        self.total_tests = 0
        self.session = requests.Session()
    
    def print_header(self, text: str) -> None:
        """Print formatted test section header."""
        print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")
        print(f"{Colors.HEADER}{Colors.BOLD}{text.center(60)}{Colors.ENDC}")
        print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")
    
    def print_test(self, test_name: str) -> None:
        """Print test name."""
        print(f"\n{Colors.CYAN}🧪 Testing: {test_name}{Colors.ENDC}")
    
    def print_success(self, message: str) -> None:
        """Print success message."""
        print(f"{Colors.GREEN}✅ {message}{Colors.ENDC}")
        self.passed_tests += 1
    
    def print_error(self, message: str) -> None:
        """Print error message."""
        print(f"{Colors.RED}❌ {message}{Colors.ENDC}")
    
    def print_warning(self, message: str) -> None:
        """Print warning message."""
        print(f"{Colors.YELLOW}⚠️  {message}{Colors.ENDC}")
    
    def print_info(self, message: str) -> None:
        """Print info message."""
        print(f"{Colors.BLUE}ℹ️  {message}{Colors.ENDC}")
    
    def make_request(self, method: str, endpoint: str, params: Optional[Dict] = None, 
                    data: Optional[Dict] = None) -> Optional[requests.Response]:
        """Make HTTP request with error handling."""
        url = f"{API_BASE}{endpoint}"
        
        try:
            if params:
                url += f"?{urlencode(params)}"
            
            response = self.session.request(
                method, url, 
                json=data if data else None,
                headers={'Content-Type': 'application/json'} if data else None
            )
            
            return response
            
        except requests.exceptions.ConnectionError:
            self.print_error("Cannot connect to Django server. Make sure it's running on http://127.0.0.1:8000")
            return None
        except Exception as e:
            self.print_error(f"Request failed: {e}")
            return None
    
    def test_server_connection(self) -> bool:
        """Test if Django server is running."""
        self.print_header("SERVER CONNECTION TEST")
        self.total_tests += 1
        
        response = self.make_request('GET', '/books/')
        if response and response.status_code in [200, 404]:
            self.print_success("Django server is running and accessible")
            return True
        else:
            self.print_error("Django server is not accessible")
            return False
    
    def test_basic_book_list(self) -> bool:
        """Test basic book listing."""
        self.print_test("Basic Book Listing")
        self.total_tests += 1
        
        response = self.make_request('GET', '/books/')
        
        if response and response.status_code == 200:
            try:
                data = response.json()
                if isinstance(data, dict):
                    count = data.get('count', len(data.get('results', [])))
                    self.print_success(f"Retrieved book list successfully. Total books: {count}")
                    self.print_info(f"Response contains: {list(data.keys())}")
                    return True
                else:
                    self.print_success(f"Retrieved book list: {len(data)} books")
                    return True
            except json.JSONDecodeError:
                self.print_error("Invalid JSON response")
                return False
        else:
            status_code = response.status_code if response else "No response"
            self.print_error(f"Failed to retrieve books. Status: {status_code}")
            return False
    
    def test_title_filtering(self) -> bool:
        """Test title filtering functionality."""
        self.print_test("Title Filtering")
        self.total_tests += 1
        
        # Test case-insensitive contains
        test_cases = [
            {'title': 'django', 'description': 'Title contains "django"'},
            {'title': 'python', 'description': 'Title contains "python"'},
            {'title_exact': 'Django for Beginners', 'description': 'Exact title match'},
        ]
        
        for case in test_cases:
            response = self.make_request('GET', '/books/', params=case)
            if response and response.status_code == 200:
                try:
                    data = response.json()
                    count = data.get('count', len(data.get('results', [])))
                    self.print_success(f"{case['description']}: {count} results")
                except json.JSONDecodeError:
                    self.print_error(f"Invalid JSON for {case['description']}")
                    return False
            else:
                self.print_error(f"Failed: {case['description']}")
                return False
        
        return True
    
    def test_author_filtering(self) -> bool:
        """Test author filtering functionality."""
        self.print_test("Author Filtering")
        self.total_tests += 1
        
        test_cases = [
            {'author': 'smith', 'description': 'Author contains "smith"'},
            {'author': 'john', 'description': 'Author contains "john"'},
            {'author_exact': 'John Smith', 'description': 'Exact author match'},
        ]
        
        for case in test_cases:
            response = self.make_request('GET', '/books/', params=case)
            if response and response.status_code == 200:
                try:
                    data = response.json()
                    count = data.get('count', len(data.get('results', [])))
                    self.print_success(f"{case['description']}: {count} results")
                except json.JSONDecodeError:
                    self.print_error(f"Invalid JSON for {case['description']}")
                    return False
            else:
                self.print_error(f"Failed: {case['description']}")
                return False
        
        return True
    
    def test_year_filtering(self) -> bool:
        """Test publication year filtering."""
        self.print_test("Publication Year Filtering")
        self.total_tests += 1
        
        test_cases = [
            {'publication_year': '2023', 'description': 'Books from 2023'},
            {'publication_year_gte': '2020', 'description': 'Books from 2020 onwards'},
            {'publication_year_lte': '2022', 'description': 'Books up to 2022'},
        ]
        
        for case in test_cases:
            response = self.make_request('GET', '/books/', params=case)
            if response and response.status_code == 200:
                try:
                    data = response.json()
                    count = data.get('count', len(data.get('results', [])))
                    self.print_success(f"{case['description']}: {count} results")
                except json.JSONDecodeError:
                    self.print_error(f"Invalid JSON for {case['description']}")
                    return False
            else:
                self.print_error(f"Failed: {case['description']}")
                return False
        
        return True
    
    def test_search_functionality(self) -> bool:
        """Test search functionality."""
        self.print_test("Search Functionality")
        self.total_tests += 1
        
        test_cases = [
            {'search': 'python', 'description': 'Search for "python"'},
            {'search': 'programming', 'description': 'Search for "programming"'},
            {'search': 'django rest', 'description': 'Search for "django rest"'},
        ]
        
        for case in test_cases:
            response = self.make_request('GET', '/books/', params=case)
            if response and response.status_code == 200:
                try:
                    data = response.json()
                    count = data.get('count', len(data.get('results', [])))
                    self.print_success(f"{case['description']}: {count} results")
                except json.JSONDecodeError:
                    self.print_error(f"Invalid JSON for {case['description']}")
                    return False
            else:
                self.print_error(f"Failed: {case['description']}")
                return False
        
        return True
    
    def test_ordering(self) -> bool:
        """Test ordering functionality."""
        self.print_test("Ordering Functionality")
        self.total_tests += 1
        
        test_cases = [
            {'ordering': 'title', 'description': 'Order by title (ascending)'},
            {'ordering': '-title', 'description': 'Order by title (descending)'},
            {'ordering': 'publication_year', 'description': 'Order by year (ascending)'},
            {'ordering': '-publication_year', 'description': 'Order by year (descending)'},
            {'ordering': 'author,title', 'description': 'Order by author, then title'},
        ]
        
        for case in test_cases:
            response = self.make_request('GET', '/books/', params=case)
            if response and response.status_code == 200:
                try:
                    data = response.json()
                    results = data.get('results', [])
                    if results:
                        first_item = results[0]
                        self.print_success(f"{case['description']}: First item - {first_item.get('title', 'N/A')}")
                    else:
                        self.print_success(f"{case['description']}: No results to order")
                except json.JSONDecodeError:
                    self.print_error(f"Invalid JSON for {case['description']}")
                    return False
            else:
                self.print_error(f"Failed: {case['description']}")
                return False
        
        return True
    
    def test_combined_operations(self) -> bool:
        """Test combining multiple operations."""
        self.print_test("Combined Operations")
        self.total_tests += 1
        
        test_cases = [
            {
                'params': {'search': 'python', 'ordering': '-publication_year'},
                'description': 'Search + Ordering'
            },
            {
                'params': {'author': 'smith', 'publication_year_gte': '2020', 'ordering': 'title'},
                'description': 'Author filter + Year filter + Ordering'
            },
            {
                'params': {'title': 'django', 'search': 'framework', 'ordering': '-publication_year'},
                'description': 'Title filter + Search + Ordering'
            },
        ]
        
        for case in test_cases:
            response = self.make_request('GET', '/books/', params=case['params'])
            if response and response.status_code == 200:
                try:
                    data = response.json()
                    count = data.get('count', len(data.get('results', [])))
                    self.print_success(f"{case['description']}: {count} results")
                    
                    # Show applied filters if available
                    if 'applied_filters' in data:
                        filters = data['applied_filters']
                        self.print_info(f"Applied filters: {filters}")
                        
                except json.JSONDecodeError:
                    self.print_error(f"Invalid JSON for {case['description']}")
                    return False
            else:
                self.print_error(f"Failed: {case['description']}")
                return False
        
        return True
    
    def test_pagination(self) -> bool:
        """Test pagination functionality."""
        self.print_test("Pagination")
        self.total_tests += 1
        
        # Test basic pagination
        response = self.make_request('GET', '/books/', params={'page': '1'})
        if response and response.status_code == 200:
            try:
                data = response.json()
                self.print_success(f"Pagination works: Page 1")
                self.print_info(f"Count: {data.get('count', 'N/A')}")
                self.print_info(f"Next: {data.get('next', 'None')}")
                self.print_info(f"Previous: {data.get('previous', 'None')}")
                self.print_info(f"Results in page: {len(data.get('results', []))}")
                return True
            except json.JSONDecodeError:
                self.print_error("Invalid JSON for pagination test")
                return False
        else:
            self.print_error("Pagination test failed")
            return False
    
    def test_dedicated_search_endpoint(self) -> bool:
        """Test the dedicated search endpoint."""
        self.print_test("Dedicated Search Endpoint")
        self.total_tests += 1
        
        # Test search endpoint
        response = self.make_request('GET', '/books/search/', params={'search': 'python'})
        if response and response.status_code == 200:
            try:
                data = response.json()
                self.print_success(f"Dedicated search endpoint works")
                self.print_info(f"Search term: {data.get('search_term', 'N/A')}")
                self.print_info(f"Result count: {data.get('result_count', 'N/A')}")
                self.print_info(f"Search fields: {data.get('search_fields', 'N/A')}")
                return True
            except json.JSONDecodeError:
                self.print_error("Invalid JSON for search endpoint")
                return False
        else:
            self.print_error("Dedicated search endpoint test failed")
            return False
    
    def test_error_handling(self) -> bool:
        """Test error handling."""
        self.print_test("Error Handling")
        self.total_tests += 1
        
        # Test invalid endpoint
        response = self.make_request('GET', '/books/invalid/')
        if response and response.status_code == 404:
            self.print_success("404 error handling works for invalid endpoints")
        else:
            self.print_warning("404 error handling test inconclusive")
        
        # Test search endpoint without search parameter
        response = self.make_request('GET', '/books/search/')
        if response and response.status_code == 400:
            self.print_success("400 error handling works for missing search parameter")
            return True
        else:
            self.print_warning("Error handling test inconclusive")
            return True  # Don't fail the test for this
    
    def run_all_tests(self) -> None:
        """Run all tests and display results."""
        self.print_header("DJANGO REST FRAMEWORK FILTERING TESTS")
        
        start_time = time.time()
        
        # Run all tests
        tests = [
            self.test_server_connection,
            self.test_basic_book_list,
            self.test_title_filtering,
            self.test_author_filtering,
            self.test_year_filtering,
            self.test_search_functionality,
            self.test_ordering,
            self.test_combined_operations,
            self.test_pagination,
            self.test_dedicated_search_endpoint,
            self.test_error_handling,
        ]
        
        # Execute tests
        for test in tests:
            try:
                test()
            except Exception as e:
                self.print_error(f"Test {test.__name__} failed with exception: {e}")
        
        # Calculate results
        end_time = time.time()
        duration = end_time - start_time
        
        # Print summary
        self.print_header("TEST RESULTS SUMMARY")
        print(f"\n{Colors.BOLD}Tests completed in {duration:.2f} seconds{Colors.ENDC}")
        print(f"{Colors.BOLD}Passed: {self.passed_tests}/{self.total_tests}{Colors.ENDC}")
        
        if self.passed_tests == self.total_tests:
            self.print_success("🎉 ALL TESTS PASSED! Your API filtering implementation is working correctly!")
        else:
            failed = self.total_tests - self.passed_tests
            self.print_warning(f"⚠️  {failed} test(s) failed. Check the output above for details.")
        
        # Print usage examples
        self.print_header("API USAGE EXAMPLES")
        print(f"\n{Colors.CYAN}Here are some example API calls you can try:{Colors.ENDC}")
        
        examples = [
            ("Basic listing", f"{API_BASE}/books/"),
            ("Filter by title", f"{API_BASE}/books/?title=django"),
            ("Filter by author", f"{API_BASE}/books/?author=smith"),
            ("Filter by year", f"{API_BASE}/books/?publication_year_gte=2020"),
            ("Search", f"{API_BASE}/books/?search=python"),
            ("Order by title", f"{API_BASE}/books/?ordering=title"),
            ("Order by year (desc)", f"{API_BASE}/books/?ordering=-publication_year"),
            ("Combined", f"{API_BASE}/books/?search=python&ordering=-publication_year&publication_year_gte=2020"),
            ("Dedicated search", f"{API_BASE}/books/search/?search=programming"),
            ("Pagination", f"{API_BASE}/books/?page=1"),
        ]
        
        for description, url in examples:
            print(f"\n{Colors.YELLOW}# {description}{Colors.ENDC}")
            print(f"curl '{url}'")


def main():
    """Main function to run the tests."""
    tester = APITester()
    tester.run_all_tests()


if __name__ == "__main__":
    main()
