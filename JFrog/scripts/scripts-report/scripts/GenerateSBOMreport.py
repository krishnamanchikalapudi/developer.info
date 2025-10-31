import inspect, logging, time, datetime

import argparse
import requests
import json
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import quote
from tqdm import tqdm
import pandas as pd
from typing import Dict, List, Tuple
from datetime import datetime
import pytz
from pathlib import Path

# Create logger but don't configure it yet
logger = logging.getLogger(__name__)

class GenerateSBOMreport:
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)

    def __init__(self, base_url: str, token: str, max_workers: int = 3, debug_level: int = 0):
        """ 
        Initialize the class with base URL, token, and other parameters 
        """
        method_name= f"{inspect.stack()[0][3]}"
        startTime = time.perf_counter()
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                     f"METHOD: {method_name} at {datetime.datetime.now()}")
        try:
            self.base_url = base_url.rstrip('/')
            self.headers = {"Authorization": f"Bearer {token}"}
            self.max_workers = max_workers
            self.debug_level = debug_level
            self.token = token  # Store token for debug curl commands
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")


    def log_curl_request(self, method: str, url: str, params: Dict = None, payload: Dict = None):
       """ 
        Log curl command for API requests
        """
        method_name= f"{inspect.stack()[0][3]}"
        startTime = time.perf_counter()
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                     f"METHOD: {method_name} at {datetime.datetime.now()}")
        try:
            if self.debug_level >= 2:  # Log all requests in verbose mode
                if params:
                    param_str = '&'.join(f"{k}={quote(str(v))}" for k, v in params.items())
                    url = f"{url}?{param_str}"
                
                logger.debug("Curl command for API request:")
                logger.debug(self.get_curl_command(url, method, payload))
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")


    def get_repository_info(self, repo_name: str) -> Tuple[str, str, str]:
        """
        Get package type and repository class using Repository Configuration API
        """
        method_name= f"{inspect.stack()[0][3]}"
        startTime = time.perf_counter()
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                     f"METHOD: {method_name} at {datetime.datetime.now()}")
        
        url = f"{self.base_url}/artifactory/api/repositories/{repo_name}"
        
        self.log_curl_request("GET", url)
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            repo_data = response.json()
            package_type = repo_data.get("packageType", "")
            rclass = repo_data.get("rclass", "")
            
            # If repository is remote, append -cache to the name
            effective_repo_name = f"{repo_name}-cache" if rclass == "remote" else repo_name
            
            if self.debug_level > 0:
                logger.debug(f"Repository {repo_name} - Type: {package_type}, Class: {rclass}")
                if rclass == "remote":
                    logger.debug(f"Using cache repository name: {effective_repo_name}")
            
            return package_type, rclass, effective_repo_name
        except Exception as e:
            logger.error(f"Error getting repository info for {repo_name}: {str(e)}")
            if self.debug_level > 0:
                logger.debug("Curl command for troubleshooting:")
                logger.debug(self.get_curl_command(url))
            return "", "", repo_name
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")


    def get_scanned_artifacts(self, repo_name: str) -> List[Dict]:
        """
        Get list of scanned artifacts using Scans List API
        """
        method_name= f"{inspect.stack()[0][3]}"
        startTime = time.perf_counter()
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                     f"METHOD: {method_name} at {datetime.datetime.now()}")
        
        url = f"{self.base_url}/xray/api/v1/artifacts"
        params = {"repo": repo_name}
        
        self.log_curl_request("GET", url, params)
        
        try:
            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()
            artifacts = response.json().get("data", [])
            
            # Debug logging if no artifacts found
            if self.debug_level > 0 and not artifacts:
                logger.debug(f"No scanned artifacts found for repository: {repo_name}")
                if self.debug_level == 1:  # Only show curl command for level 1 when there's an issue
                    full_url = f"{url}?repo={quote(repo_name)}"
                    logger.debug("Curl command for troubleshooting:")
                    logger.debug(self.get_curl_command(full_url))
            
            return artifacts
        except Exception as e:
            logger.error(f"Error getting scanned artifacts for repo {repo_name}: {str(e)}")
            if self.debug_level > 0:
                full_url = f"{url}?repo={quote(repo_name)}"
                logger.debug("Curl command for troubleshooting:")
                logger.debug(self.get_curl_command(full_url))
            return []
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")


    def get_component_name(self, artifact: Dict) -> str:
        """
        Construct component name based on package_id and version
        """
        method_name= f"{inspect.stack()[0][3]}"
        startTime = time.perf_counter()
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                     f"METHOD: {method_name} at {datetime.datetime.now()}")
        package_id = artifact.get("package_id", "")
        version = artifact.get("version", "")
        try:
            if package_id.startswith("generic://"):
                # For generic packages, extract the filename from the last part of the path
                return package_id.split("/")[-1]
            
            if "://" in package_id:
                package_id = package_id.split("://", 1)[1]
            
            if "gav://" in package_id:
                # For Maven packages
                return f"{package_id}:{version}"
            else:
                return f"{package_id}:{version}" if version else package_id
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")


    def get_curl_command(self, url: str, method: str = "GET", payload: Dict = None) -> str:
        """Generate curl command for debugging"""
        curl_cmd = f'curl -X{method} "{url}"'
        curl_cmd += ' \\\n  -H "Authorization: Bearer $MYTOKEN"'
        
        if payload:
            curl_cmd += ' \\\n  -H "Content-Type: application/json"'
            # Compress payload to single line JSON
            curl_cmd += f' \\\n  -d \'{json.dumps(payload)}\''
        
        return curl_cmd

    def get_sbom_details(self, artifact: Dict, package_type: str) -> Dict:
        """Get SBOM details using Export Component Details v2 API"""
        url = f"{self.base_url}/xray/api/v2/component/exportDetails"
        component_name = self.get_component_name(artifact)
        
        payload = {
            "package_type": package_type,
            "component_name": component_name,
            "path": artifact.get("repo_full_path", ""),
            "violations": True,
            "include_ignored_violations": True,
            "license": True,
            "security": True,
            "exclude_unknown": False,
            "vulnerabilities": True,
            "operational_risk": True,
            "secrets": True,
            "services": True,
            "applications": True,
            "iac": True,
            "output_format": "json_full",
            "spdx": True,
            "spdx_format": "json",
            "cyclonedx": True,
            "cyclonedx_format": "json"
        }

        self.log_curl_request("POST", url, payload=payload)

        try:
            response = requests.post(url, headers=self.headers, json=payload)
            response.raise_for_status()
            sbom_data = response.json()
            
            # Debug logging for zero components or errors
            if self.debug_level > 0:  # Log issues in both debug levels
                violations_count = len(sbom_data.get("violations", []))
                licenses_count = len(sbom_data.get("licenses", []))
                total_count = violations_count + licenses_count
                
                if total_count == 0:
                    logger.debug(f"Zero components found for {component_name}")
                    logger.debug(f"Original package_id: {artifact.get('package_id', '')}")
                    logger.debug(f"Original version: {artifact.get('version', '')}")
                    if self.debug_level == 1:  # Only show curl command for level 1 when there's an issue
                        logger.debug("Curl command for troubleshooting:")
                        logger.debug(self.get_curl_command(url, "POST", payload))
            
            return sbom_data
        except Exception as e:
            logger.error(f"Error getting SBOM details for {component_name}: {str(e)}")
            if self.debug_level > 0:
                logger.debug(f"Original package_id: {artifact.get('package_id', '')}")
                logger.debug(f"Original version: {artifact.get('version', '')}")
                logger.debug("Curl command for troubleshooting:")
                logger.debug(self.get_curl_command(url, "POST", payload))
            return {}

    def count_component_ids(self, sbom_data: Dict) -> Tuple[int, int, int]:
        """Count component_ids in different sections of SBOM data"""
        violations_count = len(sbom_data.get("violations", []))
        licenses_count = len(sbom_data.get("licenses", []))
        total_count = violations_count + licenses_count
        return violations_count, licenses_count, total_count

    def construct_ui_url(self, artifact: Dict) -> str:
        """Construct UI URL for SBOM software components"""
        base_path = f"{self.base_url}/ui/scans-list/repositories"
        repo_path = artifact.get("repo_full_path", "").split("/")[0]
        name = artifact.get("name", "")
        version = artifact.get("version", "")
        package_id = artifact.get("package_id", "").replace("://", "%3A%2F%2F")  # Properly encode ://
        path = artifact.get("repo_full_path", "").replace("/", "%2F")  # Properly encode /
        
        # Properly encode the name which contains forward slashes
        encoded_name = name.replace("/", "%2F")
        
        return (f"{base_path}/{repo_path}/scan-descendants/{encoded_name}?"
                f"version={quote(version)}&"
                f"package_id={package_id}&"
                f"path={path}&"
                f"page_type=sbom")

    def process_artifact(self, artifact: Dict, package_type: str) -> Dict:
        """Process a single artifact and return its details"""
        sbom_data = self.get_sbom_details(artifact, package_type)
        violations_count, licenses_count, total_count = self.count_component_ids(sbom_data)
        
        return {
            "path": artifact.get("repo_full_path", ""),
            "package_type": package_type,
            "component_name": self.get_component_name(artifact),
            'Total "component_id" in Violations section': violations_count,
            'Total "component_id" in Licenses section': licenses_count,
            'Total "component_id" across all sections': total_count,
            "sbom software components url": self.construct_ui_url(artifact)
        }

    def process_repository(self, repo_name: str) -> pd.DataFrame:
        """Process a single repository and return results as DataFrame"""
        logger.info(f"Processing repository: {repo_name}")
        
        package_type, rclass, effective_repo_name = self.get_repository_info(repo_name)
        if not package_type:
            logger.error(f"Could not determine package type for repository: {repo_name}")
            return pd.DataFrame()

        artifacts = self.get_scanned_artifacts(effective_repo_name)
        if not artifacts:
            logger.warning(f"No scanned artifacts found in repository: {effective_repo_name}")
            return pd.DataFrame()

        results = []
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = [
                executor.submit(self.process_artifact, artifact, package_type)
                for artifact in artifacts
            ]
            
            for future in tqdm(futures, desc=f"Processing {effective_repo_name}", unit="artifact"):
                try:
                    result = future.result()
                    if result:
                        results.append(result)
                except Exception as e:
                    logger.error(f"Error processing artifact: {str(e)}")

        df = pd.DataFrame(results)
        if not df.empty:
            # Create hyperlinks in the path column
            df['path'] = df.apply(lambda x: f'<a href="{x["sbom software components url"]}">{x["path"]}</a>', axis=1)
            # Drop the URL column since it's now embedded in the path
            df = df.drop(columns=['sbom software components url'])
            df = df.sort_values('Total "component_id" across all sections')
        
        return df

    def generate_html_report(self, repository_data: Dict[str, pd.DataFrame], threshold: int = 2) -> str:
        """Generate HTML report with all repository data"""
        local_tz = datetime.now().astimezone().tzinfo
        current_time = datetime.now(local_tz).strftime('%Y-%m-%d %H:%M:%S %Z')
        
        html_template = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>SBOM Software Components Analysis Report</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                h1 {{ color: #2c3e50; }}
                h2 {{ color: #34495e; margin-top: 30px; }}
                .timestamp {{ color: #7f8c8d; margin-bottom: 30px; }}
                .low-components {{ 
                    background-color: #fff3e0; 
                    padding: 15px;
                    border-radius: 5px;
                    margin: 20px 0;
                }}
                .low-components h3 {{ 
                    color: #e65100;
                    margin-top: 0;
                }}
                .low-components ul {{ 
                    list-style-type: none;
                    padding-left: 0;
                }}
                .low-components li {{ 
                    margin: 5px 0;
                }}
                table {{ border-collapse: collapse; width: 100%; margin-bottom: 30px; }}
                th, td {{ border: 1px solid #bdc3c7; padding: 8px; text-align: left; }}
                th {{ background-color: #f2f2f2; }}
                tr:nth-child(even) {{ background-color: #f9f9f9; }}
                tr.low-component {{ background-color: #fff3e0; }}
                a {{ color: #3498db; text-decoration: none; }}
                a:hover {{ text-decoration: underline; }}
                .no-data {{ color: #e74c3c; font-style: italic; }}
                .package-type-summary {{ 
                    background-color: #f8f9fa;
                    padding: 20px;
                    border-radius: 5px;
                    margin: 20px 0;
                }}
                .package-type-summary h3 {{
                    color: #2c3e50;
                    margin-top: 0;
                }}
                .package-type-bar {{
                    display: flex;
                    align-items: center;
                    margin: 10px 0;
                }}
                .bar {{
                    background-color: #34495e;
                    height: 25px;
                    margin-right: 10px;
                    min-width: 30px;
                }}
                .bar-label {{
                    font-size: 14px;
                    color: #34495e;
                }}
                .package-repos {{
                    display: none;
                    margin-left: 20px;
                    padding: 10px;
                    background-color: #fff;
                    border-left: 3px solid #34495e;
                }}
                .package-repos.active {{
                    display: block;
                }}
            </style>
            <script>
                function togglePackageRepos(packageType) {{
                    const reposDiv = document.getElementById('repos-' + packageType);
                    reposDiv.classList.toggle('active');
                }}
            </script>
        </head>
        <body>
            <h1>SBOM Software Components Analysis Report</h1>
            <div class="timestamp">Generated on: {timestamp}</div>
            {package_type_summary}
            {content}
        </body>
        </html>
        """

        # Collect package type statistics
        package_stats = {}
        package_repos = {}
        max_count = 0
        
        for repo_name, df in repository_data.items():
            if not df.empty:
                low_component_mask = df['Total "component_id" across all sections'] < threshold
                if low_component_mask.any():
                    package_type = df['package_type'].iloc[0]
                    count = low_component_mask.sum()
                    
                    # Update package stats
                    if package_type not in package_stats:
                        package_stats[package_type] = 0
                        package_repos[package_type] = []
                    package_stats[package_type] += count
                    package_repos[package_type].append((repo_name, count))
                    max_count = max(max_count, package_stats[package_type])

        # Generate package type summary section
        if package_stats:
            package_type_summary = """
            <div class="package-type-summary">
                <h3>Package Types with Low-Component Artifacts:</h3>
            """
            
            # Sort package types by count in descending order
            for package_type, count in sorted(package_stats.items(), key=lambda x: (-x[1], x[0])):
                # Calculate bar width as percentage of max count (min 5%)
                bar_width = max(5, (count / max_count) * 100)
                
                # Generate bar and make package type clickable
                package_type_summary += f"""
                <div class="package-type-bar">
                    <div class="bar" style="width: {bar_width}%;"></div>
                    <div class="bar-label">
                        <a href="javascript:void(0)" onclick="togglePackageRepos('{package_type}')">{package_type}: {count}</a>
                    </div>
                </div>
                """
                
                # Add hidden repository list for this package type
                package_type_summary += f"""
                <div id="repos-{package_type}" class="package-repos">
                    <ul>
                """
                
                # Sort repositories by count in descending order
                for repo_name, repo_count in sorted(package_repos[package_type], key=lambda x: (-x[1], x[0])):
                    package_type_summary += f'<li><a href="#repo_{repo_name}">{repo_name} ({repo_count} artifacts)</a></li>'
                
                package_type_summary += """
                    </ul>
                </div>
                """
            
            package_type_summary += "</div>"
        else:
            package_type_summary = ""

        # Generate content with anchors for repositories
        content = []
        for repo_name, df in repository_data.items():
            content.append(f'<h2 id="repo_{repo_name}">Repository: {repo_name}</h2>')
            if df.empty:
                content.append('<p class="no-data">No data available for this repository</p>')
            else:
                # Convert DataFrame to HTML
                df_html = df.to_html(
                    escape=False,
                    index=False,
                    table_id=f"table_{repo_name}",
                    classes="dataframe",
                    justify="left",
                    na_rep=""
                )
                
                # Add highlighting for low-component rows
                if (df['Total "component_id" across all sections'] < threshold).any():
                    rows = df_html.split('\n')
                    for i, row in enumerate(rows):
                        if '<tr>' in row and i-1 >= 0:  # Skip header row
                            # Get the corresponding data row from DataFrame
                            data_idx = (i-2) // 2  # Calculate DataFrame index from HTML row index
                            if data_idx < len(df) and df.iloc[data_idx]['Total "component_id" across all sections'] < threshold:
                                rows[i] = row.replace('<tr>', '<tr class="low-component">')
                    df_html = '\n'.join(rows)
                
                content.append(df_html)

        return html_template.format(
            timestamp=current_time,
            package_type_summary=package_type_summary,
            content="\n".join(content)
        )

def main():
    parser = argparse.ArgumentParser(description="Generate SBOM Software Components Report")
    parser.add_argument("--base-url", required=True, help="Artifactory base URL")
    parser.add_argument("--token", required=True, help="Access token")
    parser.add_argument("--repositories", required=True, 
                        help="Semicolon-separated repository names")
    parser.add_argument("--parallel-artifacts", type=int, default=3,
                        help="Number of artifacts to process in parallel within each repository (default: 3)")
    parser.add_argument("--parallel-repos", type=int, default=3,
                        help="Number of repositories to process in parallel (default: 3)")
    parser.add_argument("--debug-level", type=int, choices=[0, 1, 2], default=0,
                        help="Debug level: 0=no debug (default), 1=show curl commands for errors only, "
                             "2=show all curl commands")
    parser.add_argument("--threshold", type=int, default=2,
                        help="Threshold for minimum number of components (default: 2)")
    
    args = parser.parse_args()
    
    # Generate timestamp for both log and report files
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = f"sbom_report_{timestamp}.log"
    
    # Configure logging with the timestamped log file
    logging.basicConfig(
        level=logging.DEBUG if args.debug_level > 0 else logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
    )
    logger = logging.getLogger(__name__)
    
    reporter = SBOMReporter(args.base_url, args.token, args.parallel_artifacts, args.debug_level)
    
    repositories = [repo.strip() for repo in args.repositories.split(";")]
    repository_data = {}
    
    # Process repositories in parallel
    with ThreadPoolExecutor(max_workers=args.parallel_repos) as executor:
        # Create a dictionary to store futures and their corresponding repo names
        future_to_repo = {
            executor.submit(reporter.process_repository, repo_name): repo_name 
            for repo_name in repositories
        }
        
        # Use tqdm to show progress
        with tqdm(total=len(repositories), desc="Processing repositories", unit="repo") as pbar:
            for future in as_completed(future_to_repo):
                repo_name = future_to_repo[future]
                try:
                    df = future.result()
                    repository_data[repo_name] = df
                except Exception as e:
                    logger.error(f"Error processing repository {repo_name}: {str(e)}")
                    repository_data[repo_name] = pd.DataFrame()
                pbar.update(1)

    # Generate HTML report with matching timestamp
    html_report = reporter.generate_html_report(repository_data, args.threshold)
    output_file = f"sbom_analysis_report_{timestamp}.html"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html_report)
    
    logger.info(f"HTML report generated: {output_file}")
    logger.info(f"Log file generated: {log_file}")



if __name__ == "__main__":
    main()